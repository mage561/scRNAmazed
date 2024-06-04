process sayHi {
    output:
    stdout

    script:
    """
    echo Hi 
    """
}

process sayBye {
    output:
    stdout

    script:
    """
    echo Bye 
    """
}

workflow preprocessing{
    sayHi | view
}