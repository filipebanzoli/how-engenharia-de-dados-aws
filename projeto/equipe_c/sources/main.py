from projeto.equipe_c.sources.etl.webscraping import PaoDeAcucarWebScrapping


if __name__ == "__main__":
    job_scrapping = PaoDeAcucarWebScrapping("arroz")
    job_scrapping.scrapping_data()