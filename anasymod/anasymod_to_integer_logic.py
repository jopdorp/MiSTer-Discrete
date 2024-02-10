import re
import math

precision = 12  # 12 leaves 5 bits in reg [0:16] for the integer part of VCC, which is normally between 5 and 24

def convert_to_fixed_point(real_value):
    mantissa, exponent = math.frexp(real_value)
    point = abs(exponent) + precision
    fixed_point_value = round(real_value * (2 ** point))
    return fixed_point_value, point

def replace_input_real(line, inputs):
    matches = re.findall(r'`INPUT_REAL\((.*?)\)', line)
    for match in matches:
        input_signal = match
        line = f'    reg [0:15] {input_signal} \n'
        inputs += [input_signal]
    return line

def replace_make_real(line, points):
    matches = re.findall(r'`MAKE_REAL\((.*?), (.*?)\)', line)
    for match in matches:
        input_signal, output_signal = match
        line = f'    reg [0:16] {input_signal};  // Point: 12 \n\n'
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
        total_point = point + points.get(input_signal.strip(), 0) - precision
        new_expression = f'{output_signal} = ({input_signal} * {fixed_point_value}) >> {precision};  // Point: {total_point}'
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
        new_expression = f'{output_signal} = {input_signal1} + {input_signal2}'
        line = line.replace(old_expression, new_expression)
    return line, len(matches)

def replace_assign_real(line, scale_factor):
    fixed_point_scale_factor, point = convert_to_fixed_point(scale_factor)
    matches = re.findall(r'`ASSIGN_REAL\((.*?), (.*?)\)', line) 
    for match in matches:
        input_signal, output_signal = match
        old_expression = f'`ASSIGN_REAL({input_signal}, {output_signal})'
        new_expression = f'{output_signal} = ({input_signal} * {fixed_point_scale_factor}) >> {point};  // Scale factor: {scale_factor}, Point: {point}'
        line = line.replace(old_expression, new_expression)
    return line


def declare_tmp_vars(lines, tmp_var_count):
    start_of_file = ""
    for i in range(len(lines)):
        match = re.search(r'(module.*\);)', start_of_file, re.DOTALL)
        if match:
            for j in range(tmp_var_count):
                lines.insert(i + 1 + j, f'    reg[0:{16+j}] tmp{j};\n')
            lines.insert(i + 2 + j, f'\n')
            break
        start_of_file += '\n' + lines[i]
    return lines

def denormalize_inputs(lines, inputs, points, scale_factor):
    start_of_file = ""
    for i in range(len(lines)):
        match = re.search(r'(module.*\);)', start_of_file, re.DOTALL)
        if match:
            for j, input in enumerate(inputs): # TODO properly take into account point of VCC
                lines.insert(i + 1 + j, f'    wire[0:16] {input}_denormalized; // Point {precision} \n    assign {input}_denormalized = {input} * {1/scale_factor} >> {precision};\n')
                points[input + '_denormalized'] = precision
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

def convert_file(input_filename, output_filename):
    points = {}
    inputs = []
    VCC = 5
    MAX_VALUE = 2**14 - 1  # {14{1'b1}} is equivalent to 2^14 - 1
    SCALE_FACTOR = VCC / MAX_VALUE

    with open(input_filename, 'r') as input_file:
        lines = input_file.readlines()
        tmp_var_count = 0
        lines = remove_parameters(lines)
        for i in range(len(lines)):
            lines[i] = replace_input_real(lines[i], inputs)
        lines = denormalize_inputs(lines, inputs, points, SCALE_FACTOR)
        for i in range(len(lines)):
            lines[i] = replace_make_real(lines[i], points)
        for i in range(len(lines)):
            lines[i], count = replace_mul_const_real(lines[i], points, inputs)
            tmp_var_count += count
        for i in range(len(lines)):
            lines[i], count = replace_add_real(lines[i], points)
            tmp_var_count += count
        for i in range(len(lines)):
            lines[i] = replace_assign_real(lines[i], SCALE_FACTOR)
        lines = declare_tmp_vars(lines, tmp_var_count)

                  
            
    with open(output_filename, 'w') as output_file:
        output_file.writelines(lines)

# Usage:
convert_file('WalkEnAstable555.sv', 'WalkEnAstable555_fixed_point.sv')