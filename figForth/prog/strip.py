import re

with open('full.ft', 'r') as full:
    content = full.read()
    content = re.sub(r'\(.*\)', '', content) 
    content = re.sub(r'\\.*\n', '\n', content)
    words = re.split(r'[\s\n]+', content)
    words = [word for word in words if word != '']
    with open('stripped.txt', 'w') as stripped:
        stripped.write(" ".join(words))
