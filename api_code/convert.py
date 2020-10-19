import re
import requests

#-*- coding: utf-8 -*-

def get_jokes():
    
    url = 'http://bash.org.pl/text'
    file = requests.get(url)
    open('jokes.txt', 'wb').write(file.content)
    jokes = []
    pattern = re.compile(r'^#(\d+) .*$')
    joke_counter = 0

    with open ('jokes.txt', 'rt') as myfile:
        joke = []
        for line in myfile:

            line_match = pattern.match(line) 

            # start new joke
            if line == '%\n':

                # append whole joke to the list
                jokes.append({joke_id: "".join(joke)})

                # cleanup joke list
                joke = []

                # stop when 100 jokes reached
                if joke_counter == 99:
                    break
                joke_counter += 1

            elif line == "\n":
                pass

            # get joke id
            elif line_match:
                joke_id = line_match.group(1)
                # print(joke_id)

            # keep appending joke lines until % found
            else:
                joke.append(line)
    return jokes