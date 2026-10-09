
CREATE TABLE IF NOT EXISTS remote_jobs (
    job_title TEXT,
    job_description TEXT,
    company_and_category TEXT,
    job_url TEXT PRIMARY KEY,
    publication_date DATE,
    word_count INTEGER
);
SELECT COUNT(*) AS total_rows
FROM public.remote_jobs;
SELECT
    company_and_category AS job_category,
    COUNT(*) AS number_of_jobs
FROM public.remote_jobs
GROUP BY company_and_category
ORDER BY number_of_jobs DESC;


SELECT
    company_and_category AS job_category,
    COUNT(*) AS number_of_jobs,
    ROUND(AVG(word_count), 2) AS average_description_words
FROM public.remote_jobs
GROUP BY company_and_category
HAVING COUNT(*) >= 2
ORDER BY average_description_words DESC;
