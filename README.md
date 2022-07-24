# SQuEEAL!
Semantic Query Engine for Epistemic Action Logic !

## The Engine

This project aims to provide an engine for specifying agents, Kripke models, and action models to be queried by EAL formulas. Planned are two options for using *SQuEEAL!*:
- DSL: A parser for a custom DSL to specify kripke/action models and query them. The language is interpreted, and a console application will be provided to use it.
- API: An API to use the engine within code. 

At the moment, the project will be written in OCaml. However, it is expected to be translated to F#, in order to provide access to the .NET runtime, and hence make a C# API straightforward.

The engine is *semantic* because all formulas will be evaluated with respect to a provided Kripke model, utilizing Kripke semantics directly. This is **NOT** a theorem prover. There are no plans to use axiomatizations or inference rule application to evaluate the formulas, beyond simple substitutions that may speed up evaluation. The idea is to use graph algorithms and data structures to directly evaluate EAL sentences using Kripke semantics. By default, it is expected to use caching for models and short-circuited boolean operators. This however is tentative!

Standard EAL announcement operators will work out-of-the-box, but the option to define action models and hence custom operators will be supported. This is possible due to the BMS “product update” theorem (read the SEP page for more info).

The hope is to make this usable for modelling relatively complex social interactions in a videogame setting :]

## Interpreter

To run the interpreter, only an OCaml installation is needed. 

At the moment, there is no error handling or semantic analysis at the moment, so errors will be common. Plus, only Modal Logic (no dynamic/announcement operators) is supported at the moment.

To use:

```bash
make
make run
```

The syntax is meant to be very flexible. One can delimit multiple expressions in multiple lines (with `;`) or in one line (with `,`). All indentation is optional. 

There are two types of statements currently supported:
1. Kripke model definition:

Inside a kripke model definition statement one can use the `worlds`, `agents`, and `atoms` statements to specify the possible worlds, the agent relations, and the atomic sentence world assignments.

Here is an example providing all the different syntax for the statements defining a model:
```
kripke m {
    worlds: 
        1, 2, 3;
        4;
    agents a, b: 
        1->2->3;
        1->3;
    agents:
        b: 1->3, 3->2;
        c: 1->1->2;
    atoms p, q:
        1, 2;
        3;
    atoms:
        q: 4;
};

-------EVALUATED STATEMENT-------

Model id: m
Kripke Model:
1: [(1, c), (2, a), (2, b), (2, c), (3, a), (3, b), ]
2: [(3, a), (3, b), ]
3: [(2, b), ]
4: []
Atomic Assignment:
p: {1, 2, 3, }
q: {1, 2, 3, 4, }

---------------------------------
```

2. Logic formula satisfaction queries

Read as "model `m` at world `1` satisfies `[c](p & q)`:

```
m.1 := [c](p & q);        

-------EVALUATED STATEMENT-------

true

---------------------------------
```

## Background

Epistemic Action Logic (EAL) is a generalization of Public Announcement Logic (PAL), itself an extension of basic epistemic/doxastic modal logics (MLs) such as **KD45** and **S5**. MLs utilize [*Kripke models*](https://encyclopediaofmath.org/wiki/Kripke_models) to model *[possible world](https://plato.stanford.edu/entries/possible-worlds/) semantics*, the semantics used to evaluate the truth or falsity of formulas. Kripke models are directed graphs with edge labels, where vertices represent *possible worlds* and an edge `(v, a, w)` represents the notion that "agent `a` believes the world `w` is possible if `v` is the actual world". EAL and PAL are *dynamic epistemic logics* (DELs), employing dynamic operators which **modify** the underlying Kripke model, changing the truth of formulas in the language. In the case of PAL, it adds the *public announcement* operator. The formula $[\phi!]\psi$ reads: "After a public announcement of $\phi$, $\psi$ is true". Combined with the modal operator $K_a \phi$, which reads as "agent a knows/believes $\phi$", one can create sentences which describe the knowledge of agents before and after public communications. Particularly powerful is the fact that one can express *higher order belief* (or belief about belief) through this formalism. EAL is a generalization of PAL which allows one to define operators besides Public Announcement, which can describe the effects of communications such as fully private announcements, eavesdropped communication, lies, bluffs, and more. A full treatment of DELs is given in this [Stanford Encyclopedia of Philosophy page.](https://plato.stanford.edu/entries/dynamic-epistemic/)
