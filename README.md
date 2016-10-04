# Flashcards

Generate html files, "flashcards", from a simple text template


### Format

Templates will be read from the `questions` directory. There is an example file in there. Format must be:

```
<question>
text that you want on your
question
slid
</question>

<answer>
text
that you want
    on your answer
    slide
    
</answer>
```

Filename must have the `.txt` extension. All other files in the directory will be skipped.


### Usage

```
$ iex flashcards.ex
iex(1)> Flashcards.generate_site
```


### Output

Files will be generated in the output directory. For an input file of `questions/1.txt` an output of `output/q1.html` and `output/a1.html` for the question and answer, respectively
