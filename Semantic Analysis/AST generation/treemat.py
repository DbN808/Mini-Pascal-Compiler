from nltk.tree import *
import nltk.draw
import matplotlib.pyplot as plt

# Assign your output (generalized list of the syntax tree) to variable text
f = open('t1.txt', 'r')
text = f.readlines()[0]
f.close()
text = text.replace("(", "ob")  # In the syntax tree, 'ob' will display in place of '('
text = text.replace(")", "cb")  # In the syntax tree, 'cb' will display in place of ')'
text = text.replace("[", "(")
text = text.replace("]", ")")
tree = Tree.fromstring(text)


# Create a new figure
fig = plt.figure(figsize=(10, 8))

# Draw the tree with customizations
tree.draw()

# Show the plot
plt.show()
