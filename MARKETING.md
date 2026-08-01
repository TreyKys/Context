# The Context Dictionary — positioning

Everything here is grounded in what the app actually ships. Claims that can't be
backed by the build don't belong in a campaign — Play rejected us once already
for a store-listing mismatch, and misleading claims are a policy violation, not
just bad taste.

---

## The core insight

**The same word means different things in different rooms.**

- *Salty* — gaming vs. cooking vs. sailing
- *Consideration* — contract law vs. everyday English
- *Vanilla* — software vs. flavour
- *Exposure* — photography vs. finance vs. medicine
- *Sick* — illness vs. praise

Google gives you the **most common** definition. A dictionary gives you the
**most formal** one. Neither tells you what the word meant *where you just saw
it*. That gap is the product.

**One line:** *Google tells you what a word means. Context tells you what it
means here.*

---

## Who actually needs this

Ordered by how sharp the pain is, not by market size.

### 1. Non-native English speakers
The strongest segment. Grammar and vocabulary are learnable from books; **idiom,
slang, and register are not.** Dictionaries fail exactly where fluency is won.
Someone can hold a professional conversation and still be lost when a colleague
says "that's a bit of a stretch" or "no worries, ship it."

> *"You learned the language. Nobody taught you how people actually talk."*

### 2. People entering a new field
A junior nurse meeting clinical shorthand. A paralegal meeting Latin. An intern
meeting finance jargon. They can't ask — asking signals they don't belong. The
33 domain lenses map directly onto this: Medical & Clinical, Legal & Law,
Finance & Investing, Crypto & Web3, Academic & Research, and 28 more.

> *"Everyone in the room already knows. You can't be the one who asks."*

### 3. Parents and older adults
Not a joke segment — a real one. Understanding what your teenager is saying is
genuinely felt as connection, or the loss of it.

> *"Your kid isn't being difficult. They're speaking a dialect you were never taught."*

### 4. Anyone reading the internet
Slang moves faster than dictionaries can publish. By the time a word is in
Merriam-Webster, the meaning has drifted or flipped.

---

## Why not just use the alternatives

| Alternative | Where it fails |
| --- | --- |
| **Google** | Gives the dominant meaning, not the one for your domain. Ranks by popularity, not relevance to you. |
| **Urban Dictionary** | Crowdsourced and unverified. Top entries are frequently jokes, trolling, or years stale. No factual grounding. |
| **Traditional dictionaries** | Authoritative but slow. Living slang and professional jargon are largely absent. |
| **Asking a chatbot** | Works, but it's a blank box — you must know how to frame the question, and you get one flat answer with no domain switch and nothing saved. |

**The honest differentiator:** every lookup is cross-referenced against
**Wikipedia and Wiktionary** before the model answers, and results that matched a
source carry a **Verified** badge. That's a real mechanism in the code, not a
slogan — and it's precisely what Urban Dictionary cannot claim.

---

## Content angles that write themselves

Strongest first. Each is a format, not a one-off post.

1. **"One word, 25 ways."** Pick a loaded word (*salty*, *basic*, *sick*, *mid*)
   and run it through the personas. Inherently shareable, shows the product
   working, needs no explanation.
2. **"Same word, different room."** *Consideration* to a lawyer vs. everyone
   else. *Exposure* to a photographer vs. an investor. Teaches the core insight
   in six seconds.
3. **Define-from-anywhere.** Screen-record selecting a word inside X or WhatsApp
   → "Define" → the answer. The utility is self-evident and it's the feature
   nobody expects.
4. **"Explain Like I'm 5" on genuinely hard things.** *Escrow.* *Amortisation.*
   *Quantitative easing.* Broad appeal well beyond slang.
5. **Roast mode.** Pure entertainment, pure reach. Cheapest distribution in the set.

---

## Claims we can make — and the lines not to cross

**Safe, because they're true of the build:**
- Cross-referenced against Wikipedia and Wiktionary
- 33 domain contexts · 25 personas · 3 modes
- Define selected text from inside other apps
- Save words to a personal library
- Works free — 3 lookups a day, no account required

**Do not claim:**
- ❌ *"Always accurate"* / *"never wrong"* — it's an LLM. "Cross-referenced" is
  the defensible phrasing; "guaranteed correct" is not.
- ❌ *"Works in every app"* — the floating bubble cannot draw over FLAG_SECURE
  apps (banking, streaming) and needs an extra vendor permission on
  MIUI/ColorOS. Say *"from almost any app"*, and lead with the selection-menu
  path, which genuinely does work everywhere.
- ❌ *"Free"* unqualified — it's 3 lookups/day free, then ads or subscription.
  Say *"free to try, no account needed."*
- ❌ Anything about the app's look that the screenshots don't match. That is
  literally what got the first submission rejected.

---

## Before any of this goes public

- [ ] Version 5+ verified on a real device: search, library save, purchase flow,
      selection-menu lookup
- [ ] A real purchase completed end-to-end (License Tester account)
- [ ] Privacy policy + terms actually resolving at the neurodevlabs.cloud URLs
- [ ] Store listing screenshots matching the shipped cream UI
- [ ] Ads re-rendered in cream — the three existing videos are in the retired
      purple/cyan palette and contradict both the app and the store listing
