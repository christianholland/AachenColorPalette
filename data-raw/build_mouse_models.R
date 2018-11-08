# load annotation file
annotation_mgi_hgnc = read_csv("data-raw/annotation_mgi_hgnc.csv") %>%
  na.omit()

devtools::use_data(annotation_mgi_hgnc)

# Translation human PROGENy matrix to mice
progeny_matrix_human_v1 = read_csv("data-raw/progeny_matrix_human_v1.csv") %>%
  rename(gene = X1) %>%
  gather(pathway, weight, -gene) %>%
  filter(weight != 0)

progeny_matrix_mouse_v1 = progeny_matrix_human_v1 %>%
  rename(hgnc_symbol = gene) %>%
  inner_join(annotation_mgi_hgnc, by="hgnc_symbol") %>%
  group_by(hgnc_symbol, pathway) %>%
  add_count(hgnc_symbol) %>%
  mutate(weight = weight/n) %>%
  group_by(mgi_symbol, pathway) %>%
  summarise(weight = mean(weight)) %>%
  ungroup() %>%
  rename(gene = mgi_symbol) %>%
  arrange(pathway, gene)

devtools::use_data(progeny_matrix_human_v1)
devtools::use_data(progeny_matrix_mouse_v1)

# Translate human DoRothEA regulon to mice
dorothea_regulon_human_v1 = read_csv("data-raw/dorothea_regulon_human_v1.csv")

dorothea_regulon_mouse_v1 = dorothea_regulon_human_v1 %>%
  rename(hgnc_symbol = tf) %>%
  inner_join(annotation_mgi_hgnc, by="hgnc_symbol") #%>%
  distinct(tf = mgi_symbol, confidence, target, mor, likelihood) %>%
  rename(hgnc_symbol = target) %>%
  inner_join(annotation_mgi_hgnc, by="hgnc_symbol") %>%
  distinct(tf, confidence, target = mgi_symbol, mor, likelihood) %>%
  group_by(tf) %>%
  filter(confidence == max(confidence)) %>%
  ungroup() %>%
  select(tf, confidence, target, mor, likelihood)

devtools::use_data(dorothea_regulon_human_v1)
devtools::use_data(dorothea_regulon_mouse_v1)


