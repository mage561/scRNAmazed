process cowSaysHi {
    output:
    stdout

    script:
    """
    cowsay Hi
    """
}

process sayHi {
    output:
    stdout

    script:
    """
    echo Hi 
    """
}

workflow{
    sayHi() | view
    cowSaysHi() | view
}
