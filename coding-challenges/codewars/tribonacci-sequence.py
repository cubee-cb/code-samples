# takes in a list of numbers, and returns a list extended to n, each new element equal to the sum of the previous 3 elements.
# if n is less than the length, it returns up to n elements from the start.
def tribonacci(signature, n):
    output = list()
    i = 0
    while i < n:
        if i >= len(signature):
            sum = 0
            for s in range(-3,0):
                sum += output[i + s]
            output.append(sum)
        else:
            output.append(signature[i])
        i += 1
    
    return output