# 🔃 02.05 Pull Requests & Code Reviews

Pull Request (PR)—jise GitLab mein **Merge Request (MR)** kaha jata hai—ek aisa collaborative mechanism hai jahan developer apni branch ke code changes ko main codebase mein merge karne ki darkhwast karta hai. Yeh code review, quality checks, aur team discussion ka central hub hota hai.

### 02.05.01 Create a Pull Request (PR)

Pull Request technically Git CLI ka hissa nahi hota, balki hosting platforms (GitHub, GitLab, Bitbucket) dwara provide kiya gaya workflow feature hai.

#### 1. Standard Git Workflow:

```
# 1. Main branch se fresh feature branch banayein
git switch main
git pull origin main
git switch -c feature/user-authentication

# 2. Changes code karein aur commit karein
git add src/auth/
git commit -m "feat(auth): implement JWT token verification"

# 3. Branch ko remote repository par push karein
git push -u origin feature/user-authentication

```

#### 2. Opening the PR:

* Remote par push karne ke baad terminal ya platform web UI par PR creation link display hota hai.

* **Base Branch:** Jis branch mein changes lani hain (e.g., `main` ya `develop`).

* **Compare Branch:** Aapki feature branch (e.g., `feature/user-authentication`).

* **PR Description Template:**

  * **Summary:** Changes kis baare mein hain.

  * **Motivation / Ticket:** Issue tracker link (e.g., `Closes #142`).

  * **Testing Steps:** Reviewer kaise test kare.

  * **Checklist:** Unit tests added, linter passed, etc.

* **GitHub CLI (`gh`) ke zariye terminal se PR banana:**

  ```
  gh pr create --title "feat: implement JWT auth" --body "Added auth middleware and tests" --base main
  
  ```

### 02.05.02 Reviewing a PR

Code Review ka maqsad bugs pakadna, security leaks rokna, aur team ke coding standards ko enforce karna hota hai.

#### Reviewers ke liye Best Practices:

* **Constructive Feedback:** Sirf issues point out na karein, behtar solution ya pattern suggest karein.

* **Inline Suggestions:** GitHub UI mein direct code suggestions dein jinhe author 1-click se accept kar sake.

* **Review States:**

  * **Comment:** General queries ya notes jo merge ko block nahi karte.

  * **Approve:** Changes verified hain aur merge ke liye ready hain.

  * **Request Changes:** Critical bugs ya blockers hain jinhe fix kiye baghair merge nahi kiya ja sakta.

#### Reviewer ke liye Local Checkout:

Agar reviewer ko local machine par code run karke test karna ho:

```
# Remote feature branch locally pull karna
git fetch origin feature/user-authentication
git switch feature/user-authentication

# Ya GitHub CLI ke zariye
gh pr checkout 142

```

### 02.05.03 Merge Strategies (Merge, Squash, Rebase)

Jab PR approve ho jaye, to hosting platforms code integrate karne ke teen mukhtalif options dete hain:

```
Branch State Before Merge:
main:    A ─── B
                \
feature:         C ─── D

```

| Strategy | Visualization | Kaise Kaam Karta Hai | Kab Use Karein | | :--- | :