process getSampleNames {
    input:
    path samplenames

    output:
    stdout

    """
    realpath $samplenames/*
    """
}

workflow preprocessing {
    take:
    data1

    main:
    getSampleNames(data1) | view
}
