import logging


class Overwatch:
    def __init__(self) -> None:
        self.format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        self.formatter = logging.Formatter(self.format)
        logging.basicConfig(
            level=logging.INFO,
            format=self.format,
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        self.logger = logging.getLogger(__name__)

        pass

    def configure_log_file(self, filename):
        file_handler = logging.FileHandler(filename)
        file_handler.setFormatter(self.formatter)
        self.logger.addHandler(file_handler)
        return None
