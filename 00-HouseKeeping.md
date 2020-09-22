# Cheat Codes

## Why cheat codes?

* In case you want to re-do some of these scenarios later on, we have created some cheat codes, so that you can effectively "fast-forward" through an exercise

* This only makes sense either if
  * it's your second time going through the materials
  * you are not interested in the early steps and don't need to know about them

## Steps

1. Regenerate the Cheatcode Scripts:

As cloud-user on sasviya01 :

```sh
cd ~/GELVIYADEP35-deploying-viya-3.5-on-linux/
git pull
bash /opt/raceutils/cheatcodes/create.cheatcodes.sh ~/GELVIYADEP35-deploying-viya-3.5-on-linux/
```

1. Out of the list of generated files, pick the one that corresponds to the hands-on you want to fast-forward and run it using the command provided to you.

1. Don't try to skip a step. The sequence of the excercises is important, for example, you can only run the HA deployment (section 16) if you ran the new CAS server addition (section 15) before.

1. A "super script" that gather all the individual hands-on excercises is also generated : **_all.sh**.

You copy and paste a part of the content to reach a specific point in the excercices or run it as is to have all the exercises to be executed.

## Next steps

Once you are done with these instruction, close the browser tab, to go back to the main [VLE Course](https://eduvle.sas.com/course/view.php?id=1742)
