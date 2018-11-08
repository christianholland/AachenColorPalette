
# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'



#' Title
#'
#' @param E
#' @param M
#' @param gene_name
#' @param value_name
#' @param id_name
#' @param permutation
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
#' @import dplyr
#' @import purrr
#' @import furrr
#' @import tibble
#' @import tidyr
run_progeny = function (E, M, gene_name = "gene", value_name = "expression",
                        id_name = "sample", permutation = 10000, ...) {
  plan(multiprocess)
  E = E %>% mutate_if(is.factor, as.character)

  if (permutation > 0) {
    null_model = future_map_dfr(1:permutation, .progress = T, function(p) {
      E %>%
        group_by(!!!syms(id_name)) %>%
        sample_frac() %>%
        ungroup() %>%
        mutate(!!gene_name := E[[gene_name]]) %>%
        run_progeny(M, gene_name = gene_name, value_name = value_name,
                    id_name = id_name, permutation = 0)
    }) %>%
      group_by(!!!syms(id_name), pathway) %>%
      summarise(m = mean(activity),
                s = sd(activity)) %>%
      ungroup()
  }

  meta_data = E %>%
    select(-c(!!gene_name, !!value_name)) %>%
    distinct()

  emat = E %>%
    select(!!gene_name, !!id_name, !!value_name) %>%
    spread(!!id_name, !!value_name, fill = 0) %>%
    drop_na() %>%
    data.frame(row.names = 1, stringsAsFactors = F, check.names = F)

  model = M %>%
    spread(pathway, weight, fill = 0) %>%
    data.frame(row.names = 1, check.names = F, stringsAsFactors = F)

  common_genes = intersect(rownames(emat), rownames(model))
  emat_matched = emat[common_genes, , drop = FALSE] %>%
    t()
  model_matched = model[common_genes, , drop = FALSE] %>%
    data.matrix()

  stopifnot(names(emat_matched) == rownames(model_matched))

  progeny_scores = emat_matched %*% model_matched %>%
    data.frame(stringsAsFactors = F, check.names = F) %>%
    rownames_to_column(id_name) %>%
    gather(key = pathway, value = activity, -!!id_name) %>%
    as_tibble() %>%
    inner_join(meta_data, by = id_name)

  if (permutation > 0) {
    progeny_z_scores = progeny_scores %>%
      inner_join(null_model, by = c(id_name, "pathway")) %>%
      mutate(activity = (activity - m)/s) %>%
      select(!!id_name, pathway, activity)
    return(progeny_z_scores)
  }
  else {
    return(progeny_scores)
  }
}

# # load example data
# contrast_df = readRDS("~/Projects/Shiny_FUNKY/data/limma_result.rds")
# M = get(load("data/progeny_matrix_mouse_v1.rda"))
# progeny_scatter = function(contrast_df, M, contrast, pathway,
#                            top_n_labels = 10, value_id = "statistic") {
#   contrast_df %>%
#     filter(contrast == !!contrast) %>%
#     inner_join(M, by=c("gene")) %>%
#     filter(pathway == !!pathway) %>%
#     mutate(contribution = weight * !!value_id,
#            abs_contribution = abs(contribution)) %>%
#     arrange(pathway, -abs_contribution) %>%
#     group_by(pathway) %>%
#     mutate(importance = 1:n()) %>%
#     ungroup() %>%
#     mutate(lab = NA) %>%
#     mutate(lab = case_when(importance <= input$progeny_selected_top_n_labels ~ gene),
#            effect = case_when(sign(contribution) == 1 ~ "positive",
#                               sign(contribution) == -1 ~ "negative"),
#            alpha_param = case_when(!is.na(lab) ~ "1",
#                                    TRUE ~ "0")
#     ) %>%
#     ggplot(aes(x=statistic, y=weight, label=lab, color=effect)) +
#     geom_point(aes(alpha = alpha_param)) +
#     geom_hline(yintercept = c(0),
#                linetype=c(1) ,
#                color=c("black")) +
#     geom_vline(xintercept = c(0),
#                linetype=c(1) , color=c("black")) +
#     geom_label_repel(show.legend = F, na.rm = T) +
#     theme_minimal() +
#     theme(aspect.ratio = c(1)) +
#     scale_alpha_manual(values = c(0.25,1), guide="none") +
#     scale_color_manual(values = c(unname(rwth_colors["magenta"]), unname(rwth_colors["green"]))) +
#     labs(x="moderated t-value", y="PROGENy weight")
#
#   ggMarginal(scatter, type="histogram")
# }

#' Title
#'
#' @param E
#' @param regulon
#' @param gene_name
#' @param value_name
#' @param id_name
#' @param regulator_name
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
#' @import dplyr
#' @import purrr
#' @import tibble
#' @import tidyr
#' @import viper
run_viper = function(E, regulon, gene_name = "gene", value_name = "expression",
                     id_name = "sample", regulator_name = "tf",  ...) {
  meta_data = E %>%
    select(-c(!!gene_name, !!value_name)) %>%
    distinct()

  meta_regulon_data = regulon %>%
    select(-c(target, mor, likelihood)) %>%
    distinct()

  emat = E %>%
    select(!!gene_name, !!id_name, !!value_name) %>%
    spread(!!id_name, !!value_name, fill=0) %>%
    drop_na() %>%
    data.frame(row.names = 1, stringsAsFactors = F, check.names = F)

  viper_regulon = regulon %>%
    df2regulon(regulator_name = regulator_name)

  activity_scores = viper(eset = emat, regulon = viper_regulon, nes = T,
                          method = 'none', minsize = 4, eset.filter = F,
                          adaptive.size = F) %>%
    data.frame(stringsAsFactors = F, check.names = F) %>%
    rownames_to_column(var = regulator_name) %>%
    gather(key=!!id_name, value="activity", -!!regulator_name) %>%
    as_tibble() %>%
    inner_join(., meta_data, by=id_name) %>%
    inner_join(., meta_regulon_data, by = regulator_name)

  return(activity_scores)
}

#' Title
#'
#' @param df
#' @param regulator_name
#'
#' @return
#' @export
#'
#' @examples
df2regulon = function(df, regulator_name = "tf") {
  regulon = df %>%
    split(.[regulator_name]) %>%
    map(function(dat) {
      targets = setNames(dat$mor, dat$target)
      likelihood = dat$likelihood
      list(tfmode = targets, likelihood = likelihood)
      })
  return(regulon)
}


#' Title
#'
#' @param r
#' @param regultor_name
#'
#'
#' @return
#' @export
#'
#' @examples
regulon2df = function(r, regulator_name = "tf") {
  res = r %>%
    map_df(.f = function(i) {
      tf_target = i$tfmode %>%
        enframe(name = "target", value="mor") %>%
        mutate(likelihood = i$likelihood)
      },
      .id = regulator_name)
  return(res)
}
