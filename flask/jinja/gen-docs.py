#!/usr/bin/env python3

# Example of converting from some data into some output html using jinja

import os
import pprint
import sys

# pip3 install jinja2
from jinja2 import Environment, FileSystemLoader

thisdir = os.path.dirname(os.path.realpath(__file__))
output_dir = os.path.join(thisdir, 'output')

# Some example data
y = {
    'content': {
        'title': 'Hello, World!',
        'intro': 'lorem ipsum dolor si amet',
        'entries': [
            {'name': 'Kensirou', 'value': 12, 'desc': 'Lorem ipsum'},
            {'name': 'ni', 'value': 34, 'desc': 'dolor si'},
            {'name': 'yoroshiku', 'value': 56, 'desc': 'amet'},
            {'name': 'kudasai', 'value': 78, 'desc': 'sic cast'},
        ]
    }
}

# Render into html using jinja2 templating engine
env = Environment(loader=FileSystemLoader(thisdir))
template = env.get_template(os.path.join('template.html'))
output_from_parsed_template = template.render(y)
# print(output_from_parsed_template)

# to save the results
os.makedirs(output_dir, exist_ok=True)
with open(os.path.join(output_dir, "output.html"), "w") as fh:
    fh.write(output_from_parsed_template)

print('Generation complete')
