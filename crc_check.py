def crc_remainder(input_bitstring, polynomial_bitstring, initial_filler):
	'''
	Calculates the CRC remainder of a string of bits using a chosen polynomial.
	initial_filler should be '1' or '0'.
	'''
	len_polynomial = len(polynomial_bitstring)
	range_len_polynomial = range(len_polynomial)
	len_input = len(input_bitstring)
	initial_padding = initial_filler  * (len_polynomial - 1)
	input_padded_array = list(input_bitstring + initial_padding)
	while '1' in input_padded_array[:len_input]:
		cur_shift = input_padded_array.index('1')
		for i in range_len_polynomial:
			if polynomial_bitstring[i] == input_padded_array[cur_shift + i]:
				input_padded_array[cur_shift + i] = '0'
			else:
				input_padded_array[cur_shift + i] = '1'
	return ''.join(input_padded_array)[len_input:]
