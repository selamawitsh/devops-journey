# Real-World DevOps Challenge — Command History

## Scenario
You are working late on a server. You ran a long deployment command
30 minutes ago and need to run it again. The command was something
like `docker run -d -p 8080:8080 --name myapp myimage:latest`.
You do not want to retype it.

---

## Question 1
How do you find and re-run a specific command from your history
without scrolling through everything? Show two different ways.

**Method 1:**
```
Ctrl+R (reverse search)
Type a portion of the command like "docker run" and press Ctrl+R repeatedly
to cycle through matches. Press Enter to execute when found.
```
**Method 2:**
```
!docker
This runs the most recent command that starts with "docker"
You can also use !?8080? to run the most recent command containing "8080"
```

---

## Question 2
You typed a very long command and realized you made a typo at the
beginning. What keyboard shortcut jumps you to the start of the line?
What jumps you to the end?

**Jump to start:**
```
Ctrl+A
```
**Jump to end:**
```
Ctrl+E
```

---

## Question 3
Run 5 different commands. Then use history to find their line numbers.
Re-run one of them using its line number.

**Commands I ran:**
```
echo "Hello World"
date
ls -la
pwd
whoami
```
**Command I re-ran by number:**
```
 1856  echo "hello selam"
 1857  date
 1858  ls -la
 1859  pwd
 1860  whoami
 1861  clear
 1862  history
selamawit@selamawit-ThinkPad-T490:~/Desktop/devops-journey$ !1860
whoami
selamawit
selamawit@selamawit-ThinkPad-T490:~/Desktop/devops-journey$ 

```

---

## Question 4
Where does bash physically store your command history on disk?
Look inside that file. What do you see?

**File location:**
```
~/.bash_history
```
**Command I used to look inside it:**
```
tail -20 ~/.bash_history
# or
cat ~/.bash_history
# or for a cleaner view
less ~/.bash_history
```

---

