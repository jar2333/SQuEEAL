# SQuEEAL!
Semantic Query Engine for Epistemic Action Logic !

## Background

Epistemic Action Logic (EAL) is a generalization of Public Announcement Logic (PAL), itself an extension of basic epistemic/doxastic modal logics (MLs) such as **KD45** and **S5**. MLs utilize [*Kripke models*](https://encyclopediaofmath.org/wiki/Kripke_models) to model *[possible world](https://plato.stanford.edu/entries/possible-worlds/) semantics*, the semantics used to evaluate the truth or falsity of formulas. Kripke models are directed graphs with edge labels, where vertices represent *possible worlds* and an edge `(v, a, w)` represents the notion that "agent `a` believes the world `w` is possible if `v` is the actual world". EAL and PAL are *dynamic epistemic logics* (DELs), employing dynamic operators which **modify** the underlying Kripke model, changing the truth of formulas in the language. In the case of PAL, it adds the *public announcement* operator. The formula $[\phi!]\psi$ reads: "After a public announcement of $\phi$, $\psi$ is true". Combined with the modal operator $K_a \phi$, which reads as "agent a knows/believes $\phi$", one can create sentences which describe the knowledge of agents before and after public communications. Particularly powerful is the fact that one can express *higher order belief* (or belief about belief) through this formalism. EAL is a generalization of PAL which allows one to define operators besides Public Announcement, which can describe the effects of communications such as fully private announcements, eavesdropped communication, lies, bluffs, and more. A full treatment of DELs is given in this [Stanford Encyclopedia of Philosophy page.](https://plato.stanford.edu/entries/dynamic-epistemic/)

## The Engine

This project aims to provide an engine for specifying agents, Kripke models, and action models to be queried by EAL formulas. Planned are two options for using *SQuEEAL!*:
- DSL: A parser for a custom DSL to specify kripke/action models and query them. The language is interpreted, and a console application will be provided to use it.
- API: An API to use the engine within code. 

At the moment, the project will be written in OCaml. However, it is expected to be translated to F#, in order to provide access to the .NET runtime, and hence make a C# API straightforward.

The engine is *semantic* because all formulas will be evaluated with respect to a provided Kripke model, utilizing Kripke semantics directly. This is **NOT** a theorem prover. There are no plans to use axiomatizations or inference rule application to evaluate the formulas, beyond simple substitutions that may speed up evaluation. The idea is to use graph algorithms and data structures to directly evaluate EAL sentences using Kripke semantics. By default, it is expected to use lazy evaluation and short-circuited boolean operators. This however is tentative!

Standard EAL announcement operators will work out-of-the-box, but the option to define action models and hence custom operators will be supported. This is possible due to the BMS “product update” theorem (read the SEP page for more info).

The hope is to make this usable for modelling relatively complex social interactions in a videogame setting :]
