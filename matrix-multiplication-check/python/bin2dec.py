
def convert(b):
    # print("Value passed for conversion: {}\n".format(b))
    r = int(b,2)
    return r

def parse_weights(thisList):
    weight_matrix = []
    matrix_row = []
    list_matrices = []
    infoHolder = []
    get_weight_frame(2,thisList,infoHolder)
    joined_list_entries = []
    matrix_dimensions = convert(thisList[0])
    size_of_weights = convert(thisList[1])
    matrix_elements_per_line = int(16/size_of_weights)
    list_lines_per_row = int(16/matrix_elements_per_line)
    list_lines_per_matrix = int(matrix_dimensions*list_lines_per_row)
    range_start = 2
    range_end = range_start + list_lines_per_matrix

    x = range_start

    while x<range_end:
        entry = thisList[x+1].strip('\n')+ thisList[x].strip('\n')
        joined_list_entries.append(entry)
        x = x+2

    for x in range(len(infoHolder)):
        print(infoHolder[x])
        bits_per_row = infoHolder[x]['dimension'] * infoHolder[x]['size']
        for entry in thisList[infoHolder[x]['start']:infoHolder[x]['end']]:
            byteFlippedEntry = []
            if infoHolder[x]['size'] == 16:
                matrix_row.append(convert(entry))

            elif infoHolder[x]['size'] == 8:
                byteFlippedEntry = flip(entry)
                for byte in byteFlippedEntry:
                    matrix_row.append(convert(byte))

            elif infoHolder[x]['size'] == 4:
                byteFlippedEntry = flip(entry)
                nibbleFlippedEntry = []
                for byte in byteFlippedEntry:
                    for i in range(1):
                        nibbleFlippedEntry.append(flip(byte)[i])
                        nibbleFlippedEntry.append(flip(byte)[i+1])
                for nibble in nibbleFlippedEntry:
                    matrix_row.append(convert(nibble))
                nibbleFlippedEntry.clear()

            else:
                byteFlippedEntry = flip(entry)
                nibbleFlippedEntry = []
                bitFlippedEntry = []
                for byte in byteFlippedEntry:
                    for i in range(1):
                        nibbleFlippedEntry.append(flip(byte)[i])
                        nibbleFlippedEntry.append(flip(byte)[i+1])

                for nibble in nibbleFlippedEntry:
                    for i in range(1):
                        bitFlippedEntry.append(flip(nibble)[i])
                        bitFlippedEntry.append(flip(nibble)[i+1])

                # print("Converted values")
                for twobit in bitFlippedEntry:
                    matrix_row.append(convert(twobit))
                    nibbleFlippedEntry.clear()
                bitFlippedEntry.clear()

            if len(matrix_row)==infoHolder[x]['dimension']:
                weight_matrix.append(matrix_row.copy())
                matrix_row.clear()

        list_matrices.append(weight_matrix.copy())
        weight_matrix.clear()


    return list_matrices

def get_weight_frame(start, thisList, infoHolder):
    tempHolder = []
    keys = ['start', 'end', 'dimension', 'size', 'number elements']
    tempDict = dict.fromkeys(keys)
    matrix_dimensions = convert(thisList[start-2])
    tempDict['dimension'] = matrix_dimensions
    tempDict['number elements'] = matrix_dimensions * matrix_dimensions
    tempDict['start'] = start
    size_of_entries = convert(thisList[start-1])
    tempDict['size'] = size_of_entries
    bits_per_matrix = matrix_dimensions*matrix_dimensions*size_of_entries
    addRange = int(bits_per_matrix/(16))
    end = start + addRange
    tempDict['end'] = end
    tempHolder.extend((start, end, size_of_entries))
    infoHolder.append(tempDict.copy())
    if end<len(thisList)-1:
        get_weight_frame(end+2, thisList, infoHolder)
    else:
        return
    return
def flip(word):
    flipped = []
    flipped.append(word[int(len(word)/2):len(word)+1])
    flipped.append(word[0:int(len(word)/2)])
    return flipped

def get_input_frame(start, thisList, infoHolder):
    tempHolder = []
    keys = ['start', 'end', 'size', 'elements']
    tempDict = dict.fromkeys(keys)
    number_of_entries = convert(thisList[start-2])
    tempDict['elements'] = number_of_entries
    tempDict['start'] = start
    size_of_entries = convert(thisList[start-1])
    tempDict['size'] = size_of_entries
    addRange = int(number_of_entries/(16/size_of_entries))
    end = start + addRange
    tempDict['end'] = end
    tempHolder.extend((start, end, size_of_entries))
    infoHolder.append(tempDict.copy())
    if end<len(thisList)-1:
        get_input_frame(end+2, thisList, infoHolder)
    else:
        return

def parse_inputs(thisList):
    total_list_range = len(thisList)
    infoHolder = []
    get_input_frame(2, thisList, infoHolder)
    inputs = []
    all_inputs = []
    start_range = 2
    last_end_range = 0
    x = 0

    for x in range(len(infoHolder)):
        for entry in thisList[infoHolder[x]['start']:infoHolder[x]['end']]:
            byteFlippedEntry = []
            if infoHolder[x]['size'] == 16:
                inputs.append(convert(entry))

            elif infoHolder[x]['size'] == 8:
                byteFlippedEntry = flip(entry)
                for byte in byteFlippedEntry:
                    inputs.append(convert(byte))

            elif infoHolder[x]['size'] == 4:
                byteFlippedEntry = flip(entry)
                nibbleFlippedEntry = []
                for byte in byteFlippedEntry:
                    for i in range(1):
                        nibbleFlippedEntry.append(flip(byte)[i])
                        nibbleFlippedEntry.append(flip(byte)[i+1])
                for nibble in nibbleFlippedEntry:
                    inputs.append(convert(nibble))
                nibbleFlippedEntry.clear()

            else:
                byteFlippedEntry = flip(entry)
                nibbleFlippedEntry = []
                bitFlippedEntry = []
                for byte in byteFlippedEntry:
                    for i in range(1):
                        nibbleFlippedEntry.append(flip(byte)[i])
                        nibbleFlippedEntry.append(flip(byte)[i+1])

                for nibble in nibbleFlippedEntry:
                    for i in range(1):
                        bitFlippedEntry.append(flip(nibble)[i])
                        bitFlippedEntry.append(flip(nibble)[i+1])

                for twobit in bitFlippedEntry:
                    inputs.append(convert(twobit))
                nibbleFlippedEntry.clear()
                bitFlippedEntry.clear()

        byteFlippedEntry.clear()
        all_inputs.append(inputs.copy())
        inputs.clear()
    print("Input info")
    for x in range(len(infoHolder)):
        print(infoHolder[x])
    return all_inputs


def main():
    matrix_a = []
    matrix_b = []
    matrix_c = []
    matrix_d = []
    row = []
    weightLines = []
    inputLines = []
    outputLines = []
    choppedWeightLines = []
    choppedInputLines = []
    choppedOutputLines = []
    outputValues = []

    weightFile = open("../../src/inputs/weight_sram.dat")
    inputFile = open("../../src/inputs/input_sram.dat")
    outputFile = open("../../src/outputs/golden_outputs.dat")
    weightLines = weightFile.readlines()
    weightFile.close()
    inputLines = inputFile.readlines()
    inputFile.close()
    outputLines = outputFile.readlines()
    outputFile.close()



    for line in outputLines:
        tempLine = line[-17:].strip('\n')
        choppedOutputLines.append(tempLine)

    for line in choppedOutputLines:
        outputValues.append(convert(line))

    for line in weightLines:
        tempLine = line[-17:]
        choppedWeightLines.append(tempLine)

    weight_matrix = parse_weights(choppedWeightLines)

    for line in inputLines:
        tempLine = line[-17:].strip('\n')
        choppedInputLines.append(tempLine)

    inputs = parse_inputs(choppedInputLines)

    inputRanges = []
    sum = 0

    for x in inputs:
        sum += len(x)
        inputRanges.append(sum)




    outputRanges = [[0,16], [16, 32], [32, 64], [64, 96]]
    orderedOutputs = []
    for entry in outputRanges:
        orderedOutputs.append(outputValues[entry[0]:entry[1]])

    productList = []
    products = []

    for x in range(len(inputs)):
        matrix = weight_matrix[x]
        input_column = inputs[x]
        dim = len(matrix)
        product = 0
        for i in range(dim):
            sum = 0
            for j in range(dim):
                argumentA = matrix[i][j]
                argumentB = input_column[j]
                product = argumentA * argumentB
                sum += product
            products.append(sum)
        productList.append(products.copy())
        products.clear()

    # for i in range(len(productList)):
    #     print(productList[i])
    #     print(orderedOutputs[i])
    print("Run 1")
    print(inputs[0])
    print(productList[0])
    print(orderedOutputs[0])
    print("Run 2")
    print(inputs[1])
    print(productList[1])
    print(orderedOutputs[1])
    print("Run 3")
    print(inputs[2])
    print(productList[2])
    print(orderedOutputs[2])
    print("Run 4")
    print(inputs[3])
    print(productList[3])
    print(orderedOutputs[3])

    sum = 0
    accum = []
    run = 4
    run_row = 0
    matrix_row = weight_matrix[3][0]
    for x in range(len(inputs[3])):
        argA = inputs[3][x]
        argB = matrix_row[x]
        prod = argA * argB
        sum+=prod
        print("(Input){} * (Weight){} = {}\nAccumulation: {}\n".format(argA, argB, prod, sum))
    print(sum)
    return

main()
