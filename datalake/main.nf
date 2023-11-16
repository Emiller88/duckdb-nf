link = "s3://blah/blah.csv"
workflow poorman {
    DuckDB("""
           set s3_access_key_id='test';
           set s3_secret_access_key='test';
           set s3_endpoint='localhost:4566';
           set s3_use_ssl='false';
           set s3_url_style='path';

           -- display tables
           SHOW tables;
           """
    )
    DUCKDB_S3(link)
    DUCKDB_NATIVE(file(link), 100)
}

// Let DuckDB Read from s3
// This is powerful because DuckDB can pull only the parts it needs in the parquet files
process DUCKDB_S3 {

    input:
    val link // s3://blah/blah.csv

    script:
    """
    duckdb "SELECT * FROM read_csv('$link', filename=true);"
    """
}

// Stage the file for DuckDB with Nextflow
process DUCKDB_NATIVE {

    input:
    path csv // blah.csv
    val greaterthan


    script:
    """
    duckdb "SELECT * FROM read_csv('$link', filename=true);
    SELECT region FROM sales GROUP BY region HAVING sum(amount) > $greaterthan;"
    """

    // Could really just be:
    """
    cat $csv
    """
}

process DUCKDB {

    input:
    val query


    script:

    """
    duckdb :memory: "$query"
    """

}