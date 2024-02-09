import re
import math

def convert_to_fixed_point(real_value):
    mantissa, exponent = math.frexp(real_value)
    point = abs(exponent) + 12
    sign = "-" if real_value < 0 else "+"
    fixed_point_value = round(real_value * (2 ** point))
    return fixed_point_value, point, sign

def replace_mul_const_real(line, points):
    matches = re.findall(r'`MUL_CONST_REAL\((.*?), (.*?), (.*?)\)', line)
    for match in matches:
        real_value, input_signal, output_signal = match
        real_value = float(real_value)
        fixed_point_value, point, sign = convert_to_fixed_point(real_value)
        old_expression = f'`MUL_CONST_REAL({real_value}, {input_signal}, {output_signal})'
        new_expression = f'{output_signal} = {input_signal} * {fixed_point_value};  // Point: {point}, Sign: {sign}'
        line = line.replace(old_expression, new_expression)
        points[output_signal.strip()] = point
    return line

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
        new_expression = f'{output_signal} = {input_signal1} + {input_signal2};'
        line = line.replace(old_expression, new_expression)
    return line

def replace_assign_real(line, scale_factor):
    fixed_point_scale_factor, point, sign = convert_to_fixed_point(scale_factor)
    matches = re.findall(r'`ASSIGN_REAL\((.*?), (.*?)\)', line)
    for match in matches:
        input_signal, output_signal = match
        old_expression = f'`ASSIGN_REAL({input_signal}, {output_signal})'
        new_expression = f'{output_signal} = ({input_signal} * {fixed_point_scale_factor}) >> {point};  // Scale factor: {scale_factor}, Point: {point}, Sign: {sign}'
        line = line.replace(old_expression, new_expression)
    return line

def convert_file(input_filename, output_filename):
    points = {}
    VCC = 5
    MAX_VALUE = 2**14 - 1  # {14{1'b1}} is equivalent to 2^14 - 1
    SCALE_FACTOR = VCC / MAX_VALUE

    with open(input_filename, 'r') as input_file:
        lines = input_file.readlines()
        for i in range(len(lines)):
            lines[i] = replace_mul_const_real(lines[i], points)
        for i in range(len(lines)):
            lines[i] = replace_add_real(lines[i], points)
        for i in range(len(lines)):
            lines[i] = replace_assign_real(lines[i], SCALE_FACTOR)
    with open(output_filename, 'w') as output_file:
        output_file.writelines(lines)

# Usage:
convert_file('WalkEnAstable555.sv', 'WalkEnAstable555_fixed_point.sv')