create database naverdb;
use naverdb;
CREATE TABLE naver_api_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    search_keyword VARCHAR(255) NOT NULL,
    item_rank INT,
    title VARCHAR(500) NOT NULL,
    link VARCHAR(1000),
    description TEXT,
    reg_date DATETIME
);
