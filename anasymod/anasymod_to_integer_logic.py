import re
import math

fractional_precision = 12  # bits of precision for the fractional part of the fixed point number
VCC = 5
integer_precision = next(y for y in range(32) if 2**y > VCC) + 1 # plus 1 for the sign bit
high_bit = fractional_precision + integer_precision - 1 
mister_discrete_precision = 14

def convert_to_fixed_point(real_value):
    mantissa, exponent = math.frexp(real_value)
    point = abs(exponent) + fractional_precision
    fixed_point_value = round(real_value * (2 ** point))
    return fixed_point_value, point

def replace_input_real(line, inputs):
    matches = re.findall(r'`INPUT_REAL\((.*?)\)', line)
    for match in matches:
        input_signal = match
        line = f'    input signed reg[0:{mister_discrete_precision + 1}] {input_signal},\n'
        inputs += [input_signal]
    return line

def replace_make_real(line, points):
    matches = re.findall(r'`MAKE_REAL\((.*?), (.*?)\)', line)
    for match in matches:
        input_signal, output_signal = match
        line = f'    signed reg [0:{high_bit}] {input_signal};  // Point: 12 \n\n'
        points[input_signal.strip()] = 12
    return line

def replace_mul_const_real(line, points, inputs):
    matches = re.findall(r'`MUL_CONST_REAL\((.*?), (.*?), (.*?)\)', line)
    for match in matches:
        real_value, input_signal, output_signal = match

        real_value = float(real_value)
        fixed_point_value, point = convert_to_fixed_point(real_value)
        old_expression = f'`MUL_CONST_REAL({real_value}, {input_signal}, {output_signal})'
        if input_signal in inputs:
             input_signal = f'{input_signal}_denormalized'
        total_point = point + points.get(input_signal.strip(), 0) - fractional_precision
        new_expression = f'assign {output_signal} = ({{ {{ {fractional_precision}{{ {input_signal}[{high_bit}]}}}}, {input_signal} }} * {fixed_point_value}) >> {fractional_precision};  // Point: {total_point}'
        line = line.replace(old_expression, new_expression)
        points[output_signal.strip()] = total_point
    return line, len(matches)

def replace_add_real(line, points):
    matches = re.findall(r'`ADD_REAL\((.*?), (.*?), (.*?)\)', line)
    for match in matches:
        input_signal1, input_signal2, output_signal = [x.strip() for x in match]
        point1 = points.get(input_signal1, 0)
        point2 = points.get(input_signal2, 0)
        if point1 > point2:
            input_signal2 = f'({input_signal2} << {point1 - point2})'
        elif point2 > point1:
            input_signal1 = f'({input_signal1} << {point2 - point1})'
        old_expression = f'`ADD_REAL({match[0]}, {match[1]}, {match[2]})'
        new_expression = f'assign {output_signal} = {input_signal1} + {input_signal2}; // Point: {max(point1, point2)}'
        line = line.replace(old_expression, new_expression)
        points[output_signal.strip()] = max(point1, point2)
    return line, len(matches)

def replace_assign_real(line, points):
    NORMALIZED_VCC = 2**mister_discrete_precision - 1  # {14{1'b1}} is equivalent to 2^14 - 1
    scale_factor = int(NORMALIZED_VCC / VCC)

    matches = re.findall(r'`ASSIGN_REAL\((.*?), (.*?)\)', line) 
    for match in matches:
        input_signal, output_signal = match
        old_expression = f'`ASSIGN_REAL({input_signal}, {output_signal})'
        new_expression = f'assign {output_signal} = ({{ {{ {fractional_precision}{{ {input_signal}[{high_bit}]}}}}, {input_signal} }} * {scale_factor}) >> {points.get(input_signal.strip(), 0)};  // Scale factor: {scale_factor}, Point: {mister_discrete_precision}'
        line = line.replace(old_expression, new_expression)
    return line


def declare_tmp_vars(lines, tmp_var_count):
    start_of_file = ""
    for i in range(len(lines)):
        match = re.search(r'(module.*\);)', start_of_file, re.DOTALL)
        if match:
            for j in range(tmp_var_count):
                lines.insert(i + 1 + j, f'    signed wire[0:{high_bit}] tmp{j};\n')
            lines.insert(i + 2 + j, f'\n')
            break
        start_of_file += '\n' + lines[i]
    return lines

def denormalize_inputs(lines, inputs, points):
    start_of_file = ""
    for i in range(len(lines)):
        match = re.search(r'(module.*\);)', start_of_file, re.DOTALL)
        if match:
            for j, input in enumerate(inputs): # TODO properly take into account point of VCC
                lines.insert(i + 1 + j, f'    signed wire[0:{high_bit}] {input}_denormalized; // Point {fractional_precision} \n    assign {input}_denormalized = {input} * {VCC} >> {mister_discrete_precision - fractional_precision};\n')
                points[input + '_denormalized'] = fractional_precision
            lines.insert(i + 2 + j, f'\n')
            break
        start_of_file += '\n' + lines[i]
    return lines

def remove_parameters(lines):
    found_match = False
    for i in range(len(lines)):
        match = re.search(r'module.*#\(', lines[i])
        if match and not found_match:
            lines[i] = re.sub(r'#\(', '', lines[i])
            found_match = True
            continue
        if found_match:
            if re.search(r'\) ', lines[i]):
                lines[i] = '( \n'
                break
            lines[i] = ''
    return lines


def replace_output_real(code):
    return re.sub(r'`OUTPUT_REAL\((.*?)\)', r'output signed reg[0:15] \1', code)

def replace_dff_into_real(line, points):
    matches = re.findall(r'`DFF_INTO_REAL\((.*?), (.*?), (.*?), (.*?), (.*?), (.*?)\);', line)
    for match in matches:
        input_signal1, input_signal2, reset_signal, clock_signal, one, zero = [x.strip() for x in match]
        point1 = points.get(input_signal1, 0)
        point2 = points.get(input_signal2, 0)
        if point1 > point2:
            input_signal2 = f'({input_signal2} << {point1 - point2})'
        elif point2 > point1:
            input_signal1 = f'({input_signal1} << {point2 - point1})'

        new_expression = (
            f"    always @(posedge {match[3]}) begin\n"
            f"        if ({match[2]}) begin\n"
            f"            {match[1]} <= 16'b0;\n"
            f"        end else begin\n"
            f"            {match[1]} <= {input_signal2} - {input_signal1};  // Point: {max(point1, point2)}\n"
            f"        end\n"
            f"    end\n"
        )
        line = new_expression
    return line


    
def convert_file(input_filename, output_filename):
    points = {}
    inputs = []

    with open(input_filename, 'r') as input_file:
        lines = input_file.readlines()
        tmp_var_count = 0
        lines = remove_parameters(lines)
        for i in range(len(lines)):
            lines[i] = replace_input_real(lines[i], inputs)
        lines = denormalize_inputs(lines, inputs, points)
        for i in range(len(lines)):
            lines[i] = replace_make_real(lines[i], points)
        for i in range(len(lines)):
            lines[i], count = replace_mul_const_real(lines[i], points, inputs)
            tmp_var_count += count
        for i in range(len(lines)):
            lines[i], count = replace_add_real(lines[i], points)
            tmp_var_count += count
        for i in range(len(lines)):
            lines[i] = replace_assign_real(lines[i], points)
        for i in range(len(lines)):
            lines[i] = replace_output_real(lines[i])
        for i in range(len(lines)):
            lines[i] = replace_dff_into_real(lines[i], points)
        lines = declare_tmp_vars(lines, tmp_var_count)

                  
            
    with open(output_filename, 'w') as output_file:
        output_file.writelines(lines)

# Usage:
convert_file('WalkEnAstable555.sv', 'WalkEnAstable555_fixed_point.sv')