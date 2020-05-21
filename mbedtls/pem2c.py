#!/usr/bin/env python3

import argparse

parser = argparse.ArgumentParser(
    description='Convert a PEM-file into a C string that can be copy-pasted into source code.')
parser.add_argument('pemfile', type=str,
                    help='path to PEM file')
parser.add_argument('--multiline', action='store_true', default=False,
                    help='Add multiline sign (\\) to the end of each line')

args = parser.parse_args()

with open(args.pemfile, 'r', encoding='utf-8') as pf:
    for line in pf:
        if args.multiline:
            print('"{}\\r\\n" \\'.format(line.strip()))
        else:
            print('"{}\\r\\n"'.format(line.strip()))
    print('""')
