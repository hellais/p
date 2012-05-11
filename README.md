# P, a simple shell project manager

The goal of p is to provide a quick way to switch between the working
directories of various different projects that you are currently on.

It comes from the fact that I have a lot of software projects on which I am
currently working on and they are usually scattered all over the place. This
system allows you to keep track of the ones you are currently working on and
associate a quick way to access them.

It currently is tested and works on python 2.7, bash and OSX. Other
configurations may have issues.

# Quickstart

To install enter a directory where you want to store the software. Then

`git clone git://github.com/hellais/p.git`

`cd p`

`./p`

You will then need to re-apply your bash\_profile. At this point you will be
able to call p directly.

Display the list of currently tracked projects:

`p`

Add a new project to keep track of:

`p add <project_name>`

or

`p add`

Change to the directory of a project:

`p <project_name>`

Stop tracking a project:

`p rm <project_name>`

