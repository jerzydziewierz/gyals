-- This file helps my IDE to understand the database structure


CREATE TABLE IF NOT EXISTS data (reception_timestamp INTEGER, topic TEXT, payload TEXT)

CREATE INDEX IF NOT EXISTS topics ON data (topic)



/*
select
    min(reception_timestamp) as timestamp_min,
    max(reception_timestamp) as timestamp_max,
    ((max(reception_timestamp)-min(reception_timestamp))*1e-6)/60 as span_minutes
    from data
*/


/*

select
        topic,
        count(*)
    from data
    group by topic
    order by count(*) desc

*/
