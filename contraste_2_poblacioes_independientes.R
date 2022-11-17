# ---------------------------------------------- #
# --- CONTRASTE 2 POBLACIONES INDEPENDIENTES --- #
# ---------------------------------------------- #

# --- CREAR LAS POBLACIONES --- #
# Omitir esta parte y adaptar el código como se requiera...
seed(1234)
pob1 = rnorm(100, 2.5, 0.8)
pob2 = rnorm(100, 2.8, 0.75)

df <- data.frame(c(pob1, pob2), c(rep("pob1", length(pob1)), rep("pob2", length(pob2))))
colnames(df) <- c("Values", "Population")
df$Population <- as.factor(df$Population)

# --- Supuesto de la Normalidad

# Contraste estadístico de la normalidad
# p-value > 0.05, no se rechaza la hipotesis nula = se cumple la normalidad
shapiro.test(pob1)

shapiro.test(pob2)

# --- Supuesto de la Homocedasticidad u homogeneidad de varianzas
# p-value > 0.05, no se rechaza la hipotesis nula = no hay diferencias significativas en la varianza = se cumple la homogeneidad de varianzas
testVar <- var.test(pob1, pob2); testVar

# Contraste igualdad de medias
# p-value > 0.05, no se rechaza la hipotesis nula = las medias no son significativamente diferentes
t.test(
  pob1,
  pob2,
  alternative = "two.sided",
  paired = FALSE,
  var.equal = testVar$p.value > 0.05
)

rm(testVar)

# --- GRAFICAS --- #
library(ggplot2)
library(gridExtra)

# Diagrama de bigotes
g1 <- ggplot(data = df, aes(x = Population, y = Values, fill = Population)) + 
  stat_boxplot(geom = "errorbar", width = 0.25) + 
  geom_boxplot() +
  stat_summary(fun="mean", color="white", shape=15) +
  ylab("Values") +
  ggtitle("Boxplot")

# Número de individuos por nivel
t1 <- tableGrob(as.data.frame(table(df$Population)))

# Comprobación gráfica de la normalidad
gQQ1 <- ggplot(df[df$Population == "pob1",], aes(sample = Values)) + 
  stat_qq() + 
  stat_qq_line() +
  theme(axis.title =element_text(size = 9)) +
  ylab("QQplot pob1")

gQQ2 <- ggplot(df[df$Population == "pob2",], aes(sample = Values)) + 
  stat_qq() + 
  stat_qq_line() +
  theme(axis.title = element_text(size = 9)) +
  ylab("QQplot pob2")

# Gráfico final
grid.arrange(gQQ1, gQQ2, t1, g1, 
             widths = c(1, 1, 2), 
             layout_matrix = rbind(c(1, 2, 4), c(3, 3, 4)))

rm(male, female, g1, t1, gQQ1, gQQ2)
