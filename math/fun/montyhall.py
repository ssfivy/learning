#!/usr/bin/env python3
#simulates monty hal problem

from random import shuffle, choice

tests = 10000

results_switched = [0] * tests
results_stayed = [0] * tests

def runtest(isSwitch, result):
    for i in range(tests):
        # Generate random prize sequence
        all_doors_contents = ['Prize', 'Goat', 'Goat']
        shuffle(all_doors_contents)

        # Blindly guess which is the prize
        picked_door = choice([0,1,2])

        # Randomly reveal which other door is not prize
        not_picked_doors = [0,1,2]
        not_picked_doors.remove(picked_door) #which doors are not picked?
        shuffle(not_picked_doors) #Randomly....
        for j in not_picked_doors: 
            if all_doors_contents[j] == 'Goat': #...show a door with a goat behind it
                #import pdb; pdb.set_trace()
                revealed_goat = j #there's a goat behind this door!
                not_picked_doors.remove(j) 
                door_not_picked_not_revealed = not_picked_doors[0] #this last door we didn't pick, and it's not revealed
                break;

        # Do we change our choice?
        if isSwitch:
            picked_door = door_not_picked_not_revealed

        # and we reveal what we get!
        if all_doors_contents[picked_door] == 'Prize':
            result[i] = 1

runtest(True, results_switched)
runtest(False, results_stayed)
print('Switched: Success: {0} out of {1} tries ({2}%)'.format(sum(results_switched), tests, sum(results_switched)*100/tests))
print('Stayed:   Success: {0} out of {1} tries ({2}%)'.format(sum(results_stayed), tests, sum(results_stayed)*100/tests))
