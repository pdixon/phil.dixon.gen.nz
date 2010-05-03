---
layout: note
section: Reference
---

# Submodules

To add a submodule to a project:

    git submodule add REPO PATH

After cloning a project containing submodules:

    git submodule init
    git submodule update


To update the submodule:

    cd PATH
    git checkout master
    git pull
    cd -
    git commit -am"Updated stuff"`


# References

* <http://gaarai.com/2009/04/20/git-submodules-adding-using-removing-and-updating/>
