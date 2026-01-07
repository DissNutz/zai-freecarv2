CREATE TABLE `zaineee_freecar` (
  `identifier` varchar(255) NOT NULL,
  `plate` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;