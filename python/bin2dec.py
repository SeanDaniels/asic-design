import numpy as np

def convert(b):
    r = int(b,2)
    return r

def main():
    matrix_a = []
    matrix_b = []
    matrix_c = []
    matrix_d = []
    lines = []
    choppedLines = []
    row = []
    myFile = open("../src/inputs/564_final_inputs_0.dat")
    lines = myFile.readlines()
    myFile.close()

    for line in lines:
        choppedLines.append(line[-16:])


    # for line in lines:
    #     decValues.append(convert(line[-16:]))

    numberOfEntries = convert(choppedLines[0])
    sizeOfEntries =  convert(choppedLines[1])
    entriesPerRead = 16/sizeOfEntries
    readsNeeded = numberOfEntries/entriesPerRead
    stopIndex = 2 + readsNeeded

    print("(matrix_a)Number of entries: {}\n".format(numberOfEntries))
    print("(matrix_a)Size of entries: {}\n".format(sizeOfEntries))
    print("(matrix_a)Entries per read: {}\n".format(entriesPerRead))
    print("(matrix_a)Reads needed: {}\n".format(readsNeeded))
    print("(matrix_a)Stop index: {}\n".format(stopIndex))

    numberOfReads = 0
    matrixReads = 0
    startIndex = 2
    for entry in choppedLines[startIndex:int(stopIndex)]:
        row.append(convert(entry[0:sizeOfEntries-1]))
        row.append(convert(entry[sizeOfEntries:]))
        matrix_a.append(row.copy())
        row.clear()

    startIndex = int(stopIndex)
    numberOfEntries = convert(choppedLines[startIndex])
    sizeOfEntries = convert(choppedLines[startIndex+1])
    entriesPerRead = 16/sizeOfEntries
    readsNeeded = numberOfEntries/entriesPerRead
    startIndex = startIndex+2
    stopIndex = startIndex + readsNeeded

    print("(matrix_b)Next number of entries: {}\nRead from file index {}\n".format(numberOfEntries, startIndex-2))
    print("(matrix_b)Next size of entries: {}\n".format(sizeOfEntries))
    print("(matrix_b)Next entries per read: {}\n".format(entriesPerRead))
    print("(matrix_b)Next reads needed: {}\n".format(readsNeeded))
    print("(matrix_b)Next start index: {}\n".format(startIndex))
    print("(matrix_b)Next stop index: {}\n".format(stopIndex))

    for entry in choppedLines[startIndex:int(stopIndex)]:
        row.append(convert(entry[0:sizeOfEntries-1]))
        row.append(convert(entry[sizeOfEntries:]))
        matrix_b.append(row.copy())
        row.clear()
    #@14
    startIndex = int(stopIndex)
    numberOfEntries = convert(choppedLines[startIndex])
    sizeOfEntries = convert(choppedLines[startIndex+1])
    entriesPerRead = 16/sizeOfEntries
    readsNeeded = numberOfEntries/entriesPerRead
    startIndex = startIndex+2
    stopIndex = startIndex + readsNeeded

    print("(matrix_c)Next number of entries: {}\nRead from file index {}\n".format(numberOfEntries, startIndex-2))
    print("(matrix_c)Next size of entries: {}\n".format(sizeOfEntries))
    print("(matrix_c)Next entries per read: {}\n".format(entriesPerRead))
    print("(matrix_c)Next reads needed: {}\n".format(readsNeeded))
    print("(matrix_c)Next start index: {}\n".format(startIndex))
    print("(matrix_c)Next stop index: {}\n".format(stopIndex))
    print("(matrix_c)Number of reads: {}\n".format(numberOfReads))

    start = int(0)
    for entry in choppedLines[startIndex:int(stopIndex)]:
        row.append(convert(entry[0:1]))
        row.append(convert(entry[2:3]))
        row.append(convert(entry[4:5]))
        row.append(convert(entry[5:6]))
        row.append(convert(entry[7:8]))
        row.append(convert(entry[9:10]))
        row.append(convert(entry[11:12]))
        row.append(convert(entry[13:14]))
        row.append(convert(entry[14:15]))
        row.append(convert(entry[sizeOfEntries:]))
        matrix_c.append(row.copy())
        row.clear()

    startIndex = int(stopIndex)
    numberOfEntries = convert(choppedLines[startIndex])
    sizeOfEntries = convert(choppedLines[startIndex+1])
    entriesPerRead = 16/sizeOfEntries
    readsNeeded = numberOfEntries/entriesPerRead
    startIndex = startIndex+2
    stopIndex = startIndex + readsNeeded

    print("(matrix_d)Next number of entries: {}\nRead from file index {}\n".format(numberOfEntries, startIndex-2))
    print("(matrix_d)Next size of entries: {}\n".format(sizeOfEntries))
    print("(matrix_d)Next entries per read: {}\n".format(entriesPerRead))
    print("(matrix_d)Next reads needed: {}\n".format(readsNeeded))
    print("(matrix_d)Next start index: {}\n".format(startIndex))
    print("(matrix_d)Next stop index: {}\n".format(stopIndex))
    print("(matrix_d)Number of reads: {}\n".format(numberOfReads))


    for entry in choppedLines[startIndex:int(stopIndex)]:
        row.append(convert(entry[0:sizeOfEntries-1]))
        row.append(convert(entry[sizeOfEntries:]))
        matrix_c.append(row.copy())
        row.clear()

    print(matrix_a)
    print(matrix_b)
    print(matrix_c)


main()
