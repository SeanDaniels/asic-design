def convert(b):
    # print("Value passed for conversion: {}\n".format(b))
    r = int(b,2)
    return r

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

def parse_weights(thisList, weightInfoList):
    weight_matrix = []
    matrix_row = []
    list_matrices = []
    weightInfo = []
    get_weight_frame(2,thisList,weightInfo)
    weightInfoList.append(weightInfo.copy())
    joined_list_entries = []
    matrix_dimensions = convert(thisList[0])
    size_of_weights = convert(thisList[1])
    matrix_elements_per_line = int(16/size_of_weights)
    list_lines_per_row = int(16/matrix_elements_per_line)
    list_lines_per_matrix = int(matrix_dimensions*list_lines_per_row)
    range_start = 2
    range_end = range_start + list_lines_per_matrix

    for x in range(len(weightInfo)):
        bits_per_row = weightInfo[x]['dimension'] * weightInfo[x]['size']
        for entry in thisList[weightInfo[x]['start']:weightInfo[x]['end']]:
            byteFlippedEntry = []
            if weightInfo[x]['size'] == 16:
                matrix_row.append(convert(entry))

            elif weightInfo[x]['size'] == 8:
                byteFlippedEntry = flip(entry)
                for byte in byteFlippedEntry:
                    matrix_row.append(convert(byte))

            elif weightInfo[x]['size'] == 4:
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

            if len(matrix_row)==weightInfo[x]['dimension']:
                weight_matrix.append(matrix_row.copy())
                matrix_row.clear()

        list_matrices.append(weight_matrix.copy())
        weight_matrix.clear()


    return list_matrices

def parse_inputs(thisList, inputInfoList):
    total_list_range = len(thisList)
    inputInfo = []
    get_input_frame(2, thisList, inputInfo)
    inputInfoList.append(inputInfo.copy())
    inputs = []
    all_inputs = []
    start_range = 2
    last_end_range = 0
    x = 0

    for x in range(len(inputInfo)):
        for entry in thisList[inputInfo[x]['start']:inputInfo[x]['end']]:
            byteFlippedEntry = []
            if inputInfo[x]['size'] == 16:
                inputs.append(convert(entry))

            elif inputInfo[x]['size'] == 8:
                byteFlippedEntry = flip(entry)
                for byte in byteFlippedEntry:
                    inputs.append(convert(byte))

            elif inputInfo[x]['size'] == 4:
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
    return all_inputs

def parse_file(thisFile):
    fileLines = []
    parsedFileLines = []
    currentFile = open(thisFile)
    fileLines = currentFile.readlines()
    currentFile.close()
    for line in fileLines:
        strippedLine = line[-17:].strip('\n')
        parsedFileLines.append(strippedLine)

    return parsedFileLines

def get_result_ranges(inputList, outputList):
    resultRanges = []
    orderedOutputs = []
    start = 0
    for entry in inputList:
        end = start + len(entry)
        resultRange = [start, end]
        resultRanges.append(resultRange.copy())
        resultRange.clear()
        orderedOutputs.append(outputList[start:end].copy())
        start = end

    return orderedOutputs


def get_results(numberOfRuns, matrixList, inputList):
    result = []
    resultList = []
    for x in range(numberOfRuns):
        currentMatrix = matrixList[x]
        currentInputList = inputList[x]
        dim = len(currentMatrix)
        product = 0
        for i in range(dim):
            sum = 0
            for j in range(dim):
                argA = currentMatrix[i][j]
                argB = currentInputList[j]
                product = argA * argB
                sum+=product
            result.append(sum)
        resultList.append(result.copy())
        result.clear()

    return resultList


def print_row(matrixNumber, rowNumber, inputList, matrixList, resultList):
    matrix = matrixList[matrixNumber]
    inputs = inputList[matrixNumber]
    matrixRow = matrix[rowNumber]
    result = resultList[matrixNumber][rowNumber]
    print(matrixRow)
    print(inputs)
    print(result)
    return

def main():
    row = []
    weightLines = []
    inputLines = []
    outputLines = []
    outputValues = []
    results = []
    weightInfoList = []
    inputInfoList = []
    weightFile = "../../src/input_1/weight_sram.dat"
    goldenOutputFile = "../../src/input_1/golden_outputs.dat"
    inputFile = "../../src/input_1/input_sram.dat"


    matrixList = parse_weights(parse_file(weightFile),weightInfoList)
    inputList = parse_inputs(parse_file(inputFile), inputInfoList)
    for line in parse_file(goldenOutputFile):
        outputValues.append(convert(line))


    orderedOutputs = get_result_ranges(inputList, outputValues)
    productList = []
    products = []
    results = get_results(len(inputList), matrixList, inputList)

    # for x in range(len(results)):
    #     matrix = weight_matrices[x]
    #     inputs = inputs[x]
    #     result = results[x]
    #     print("Run {}\n".format(x))
    #     print("Matrix:\n")
    #     print(weightInfoList[0][x])
    #     for entry in matrix:
    #         print(entry)
    #     print("\nInputs:")
    #     print(inputInfoList[0][x])
    #     for entry in inputs:
    #         print(entry)
    #     print("\nResults:")
    #     for entry in result:
    #         print(entry)
    matrixNumber = 0
    rowNumber = 3
    print_row(matrixNumber, rowNumber, inputList, matrixList, results)
    return

main()
