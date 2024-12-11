import re

def strip(name):
    with open(f"{name}.4th", 'r') as full:
        content = full.read()
        content = re.sub(r'\( .*\)', '', content) 
        content = re.sub(r'\\ .*\n', '\n', content)
        words = re.split(r'[\s\n]+', content)
        words = [word for word in words if word != '']
        with open(f"{name}.txt", 'w') as stripped:
            stripped.write(" ".join(words))

strip('full')
strip('benchmark')
strip('fullNative')
