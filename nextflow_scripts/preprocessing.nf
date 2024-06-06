process getSamplePathes {
    input:
    path samplerepo

    output:
    stdout

    """
    realpath $samplerepo/*
    """
}


workflow preprocessing {
    take:
    data1

    main:
    getSamplePathes(data1) | view
}
