import numpy as np

def convert(b):
    # print("Value passed for conversion: {}\n".format(b))
    r = int(b,2)
    return r

def parse_weights(thisList):
    weight_matrix = []
    matrix_row = []
    joined_list_entries = []

    matrix_dimensions = convert(thisList[0])
    size_of_weights = convert(thisList[1])
    matrix_elements_per_line = int(16/size_of_weights)
    list_lines_per_row = int(16/matrix_elements_per_line)
    print("Weight sram")
    print("Matrix dimensions: {}\nSize of entries: {}\n".format(matrix_dimensions, size_of_weights))
    list_lines_per_matrix = int(matrix_dimensions*list_lines_per_row)
    range_start = 2
    range_end = range_start + list_lines_per_matrix
    # print("Number of elements per line: {}\nNumber of lines per row: {}\nNumber of lines per matrix {}\n".format(matrix_elements_per_line, list_lines_per_row, list_lines_per_matrix))
    x = range_start

    while x<range_end:
        entry = thisList[x+1].strip('\n')+ thisList[x].strip('\n')
        joined_list_entries.append(entry)
        x = x+2

    # print(len(joined_list_entries))
    # print(joined_list_entries)


    #     row.append(convert(entry[0:sizeOfEntries-1]))
    #     row.append(convert(entry[sizeOfEntries:]))

    for x in range(len(joined_list_entries)):
        # print("Entry being parsed: {}\n".format(entry))
        end = len(joined_list_entries[x]) - 1
        convertArgument = []
        if size_of_weights == 2:
            for y in range(16):
                start = end - 1
                convertArgument = joined_list_entries[x][start] + joined_list_entries[x][end]
                matrix_row.append(convert(convertArgument))
                end = start - 1
            # print("Length of matrix row (should be 16): {}\n".format(len(matrix_row)))
            # print("Matrix row: {}\n".format(matrix_row))
            weight_matrix.append(matrix_row.copy())
            matrix_row.clear()

    return weight_matrix


def parse_inputs(thisList):
    # print("Input sram")
    number_of_entries = convert(thisList[0])
    size_of_entries = convert(thisList[1])
    # print("Number of entries: {}\nSize of entries: {}\n".format(number_of_entries, size_of_entries))
    run_ranges = []
    start_range = 2
    inputs = []
    for entry in thisList[2:10]:
        start = 0
        if size_of_entries == 8:
            flipEntry = entry[8:17] + entry[0:8]
            # print("OG: {}\n Flipped: {}\n".format(entry, flipEntry))
            end = size_of_entries
            for x in range(2):
                # print("Start: {} End: {}".format(start, end))
                end = start + size_of_entries
                # print(entry)
                # print(entry[0:8])
                # print(8*" " + entry[8:16])
                # print(len(entry))
                convertArgument = flipEntry[start:end]
                start = end

                # print("Input being converted: {}\n".format(convertArgument))
                inputs.append((convert(convertArgument)))

    # 00000010 | 00000111
    # start_range = run_ranges[0][1]+1
    # number_of_entries = convert(thisList[start_range])
    # size_of_entries = convert(thisList[start_range+1])
    # print("Range of entries for run 0: {}\nNext start range: {}\n".format(run_ranges[0], start_range))
    return inputs

def main():
    matrix_a = []
    matrix_b = []
    matrix_c = []
    matrix_d = []
    row = []
    weightLines = []
    inputLines = []
    choppedWeightLines = []
    choppedInputLines = []

    weightFile = open("../../src/inputs/weight_sram.dat")
    inputFile = open("../../src/inputs/input_sram.dat")
    weightLines = weightFile.readlines()
    weightFile.close()
    inputLines = inputFile.readlines()
    inputFile.close




    for line in weightLines:
        tempLine = line[-17:]
        choppedWeightLines.append(tempLine)

    weight_matrix = parse_weights(choppedWeightLines)

    for line in inputLines:
        tempLine = line[-17:].strip('\n')
        choppedInputLines.append(tempLine)

    inputs = parse_inputs(choppedInputLines)


    # sum = 0
    # print("Row 0")
    # print("Input Coef | Weight Coef | Product | Accumulation |")
    # for i in range(len(weight_matrix[0])):
    #     argumentA = weight_matrix[0][i]
    #     argumentB = inputs[i]
    #     product = argumentA * argumentB
    #     sum += product
    #     print("{}|{}|{}|{}|\n".format(argumentB, argumentA, product, sum))

    print("Number of input rows:{}\n".format(len(inputs)))
    print("Number of matrix columns: {}\n".format(len(weight_matrix[0])))
    print("Inputs: {}\n".format(inputs))
    print("Weight Matrix Row 0: {}\n".format(weight_matrix[0]))
    for i in range(len(weight_matrix)):
        print("Row {}: {}\n".format(i, weight_matrix[i]))

    for j in range(len(weight_matrix)):
        print("Row {}".format(j))
        print("Input Coef | Weight Coef | Product | Accumulation |")
        sum = 0
        for i in range(len(weight_matrix)):
            argumentA = weight_matrix[j][i]
            argumentB = inputs[i]
            product = argumentA * argumentB
            sum += product
            print("{}|{}|{}|{}|\n".format(argumentB, argumentA, product, sum))

    # print("Row 2")
    # print("Input Coef | Weight Coef | Product | Accumulation |")
    # sum = 0
    # for i in range(len(weight_matrix[2])):
    #     argumentA = weight_matrix[2][i]
    #     argumentB = inputs[i]
    #     product = argumentA * argumentB
    #     sum += product
    #     print("{}|{}|{}|{}|\n".format(argumentB, argumentA, product, sum))

    return

main()
