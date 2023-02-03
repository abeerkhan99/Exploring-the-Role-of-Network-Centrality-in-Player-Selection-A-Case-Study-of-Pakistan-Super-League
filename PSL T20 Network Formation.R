library(igraph)
library(sqldf)
library(DirectedClustering)
library(reshape2)

# install.packages("sqldf")
# install.packages('DirectedClustering')

# set working directory Ctrl+Shift+H

pakistani_players = read.csv("psl_pakistani_players.csv")
team_data = read.csv("psl_players_team_data.csv")
eligible_batter = read.csv("eligible batter.csv")
eligible_bowler = read.csv("eligible bowler.csv")
eligible_allrounder = read.csv("eligible all-rounder.csv")
eligible_wc = read.csv("eligible wicket-keeper.csv")

# FOR SEASONAL NETWORKS / temporal analysis

## change of dates accordingly
peshawar_zalmi = sqldf('select "Player.Name" from team_data where "X2022" == "Peshawar Zalmi"')
lahore_qalandars = sqldf('select "Player.Name" from team_data where "X2022" == "Lahore Qalandars"')
karachi_kings = sqldf('select "Player.Name" from team_data where "X2022" == "Karachi Kings"')
islamabad_united = sqldf('select "Player.Name" from team_data where "X2022" == "Islamabad United"')
quetta_gladiators = sqldf('select "Player.Name" from team_data where "X2022" == "Quetta Gladiators"')
multan_sultans = sqldf('select "Player.Name" from team_data where "X2022" == "Multan Sultans"')

edge_list = read.csv("psl2022_edgelist.csv")
g = graph_from_data_frame(edge_list, directed = T)
E(g)$width = edge_list$Matches/3

V(g)$color[names(V(g)) %in% peshawar_zalmi$Player.Name] = "yellow"
V(g)$color[names(V(g)) %in% karachi_kings$Player.Name] = "orange"
V(g)$color[names(V(g)) %in% islamabad_united$Player.Name] = "red"
V(g)$color[names(V(g)) %in% quetta_gladiators$Player.Name] = "purple"
V(g)$color[names(V(g)) %in% multan_sultans$Player.Name] = "blue"
V(g)$color[names(V(g)) %in% lahore_qalandars$Player.Name] = "green"

plot(g, margin = -0.2, vertex.size = 7, layout = layout.kamada.kawai(g), 
     vertex.label = NA, vertex.shape = "circle", edge.arrow.size = 0.3, 
     vertex.color = V(g)$color)
Group <- gl(6, 6, labels = c("Peshawar Zalmi", "Karachi Kings", 
                             "Islamabad United", "Quetta Gladiators", 
                             "Multan Sultans", "Lahore Qalandars"))
legend("bottomleft",bty = "n",
       legend=levels(Group),
       fill= c("yellow", "orange", "red", "purple", "blue", "green"), border=NA)
mtext("PSL 2022 Network", font=2, cex=2, side = 4, line = -14, las = 2)

## average path length 
average.path.length(g)

## closeness
mean(closeness(g))

## degree distribution
mean(degree(g))

## betweenness
mean(betweenness(g))

## global clustering
### make adjacency matrix - for the new clustering library
A = get.adjacency(g, sparse = FALSE, attr = "width")
transitivity(g)
clustering = ClustBCG(A, "directed")
global_clustering = clustering$GlobaltotalCC
print(global_clustering)

# FOR ENTIRE NETWORK 

edge_list = read.csv("entire_psl_edgelist.csv")
g = graph_from_data_frame(edge_list, directed = T)
E(g)$width = edge_list$Matches

## make adjacency matrix - for the new clustering library
A = get.adjacency(g, sparse = FALSE, attr = "width")

E(g)$width = edge_list$Matches/10

## dark green nodes indicate pakistani players, dark red nodes indicate international players
V(g)$color = ifelse(names(V(g)) %in% pakistani_players$Player.Name, "dark green", "dark red")
plot(g, margin = -0.2, vertex.size = 5, layout = layout.kamada.kawai(g), 
     vertex.label = NA, vertex.shape = "circle", edge.arrow.size = 0.05, 
     vertex.color = V(g)$color, edge.width = E(g)$width)

Group <- gl(2, 2, labels = c("Pakistani player","International player"))
legend("bottomleft",bty = "n",
       legend=levels(Group),
       fill= c("dark green", "dark red"), border=NA)
mtext("PSL T20 Network", font=2, cex=2, side = 4, line = -14, las = 2)

## FOR NETWORK ANALYSIS 

vcount(g) 
average.path.length(g)
diameter(g)
edge_density(g)

## DEGREE
deg_g = degree(g)
degree(g)
max(deg_g)
min(deg_g)
mean(deg_g)
hist_degree = hist(degree(g), xlim=c(2,252), col="light green", main = "") 
mtext("Degree Distribution of PSL Network", font=2, cex=2, side = 3)
hist_degree
max(hist_degree$counts)
min(hist_degree$counts)

### for team selection
eligible_deg = degree(g)[eligible_batter$Player]
sort(eligible_deg, decreasing = TRUE)
#### change spreadsheet for diff roles
degree(g)[eligible_batter$Player]
degree(g)[eligible_wc$Player]
degree(g)[eligible_allrounder$Player]
degree(g)[eligible_bowler$Player]

## CLUSTERING COEFFICIENT
### using another library for directed network calculation
clustering = ClustBCG(A, "directed")
local_clustering = clustering$totalCC
print(local_clustering)
min(local_clustering)
max(local_clustering)
global_clustering = clustering$GlobaltotalCC
print(global_clustering)
hist_cc = hist(local_clustering, main = "", 
               xlab = "Local Clustering", col="light green")
mtext("Local Clustering Coefficient Distribution of PSL Network", 
      font=2, cex=2, side = 3)
hist_cc
max(hist_cc$counts)
min(hist_cc$counts)

#### for team selection
reshape_cc = melt(local_clustering, c("Player", "CC"))
filter_var = c("Player", "value")
df = reshape_cc[filter_var]
print(df[order(df$value, decreasing = TRUE), ])

bowler = df %>% 
  filter(Player %in% eligible_bowler$Player)

batter = df %>% 
  filter(Player %in% eligible_batter$Player)

ar = df %>% 
  filter(Player %in% eligible_allrounder$Player)

wc = df %>% 
  filter(Player %in% eligible_wc$Player)


## BETWEENNESS 
### to normalize values
options(scipen = 999)

betweenness(g)
mean(betweenness(g))
max(betweenness(g))
min(betweenness(g))
hist_btw = hist(betweenness(g), main = "", col="light green")
mtext("Betweenness Distribution of PSL Network", font=2, cex=2, side = 3)
hist_btw
max(hist_btw$counts)
min(hist_btw$counts)

### for team selection
eligible_btw = betweenness(g)[eligible_batter$Player]
sort(eligible_btw, decreasing = TRUE)
#### change category for diff roles
betweenness(g)[eligible_batter$Player]
betweenness(g)[eligible_bowler$Player]
betweenness(g)[eligible_allrounder$Player]
betweenness(g)[eligible_wc$Player]

## CLOSENESS 
closeness(g)
mean(closeness(g))
closeness(g)
max(closeness(g))
min(closeness(g))
hist_close = hist(closeness(g), main = "", col="light green")
mtext("Closeness Distribution of PSL Network", font=2, cex=2, side = 3)
hist_close
max(hist_close$counts)
min(hist_close$counts)

### for team selection
eligible_close = closeness(g)[eligible_batter$Player]
sort(eligible_close, decreasing = TRUE)
#### change category for diff roles
closeness(g)[eligible_batter$Player]
closeness(g)[eligible_bowler$Player]
closeness(g)[eligible_allrounder$Player]
closeness(g)[eligible_wc$Player]

# FOR SEMINAL MODELS

## generating ER Random Graph
### where g is the entire network generated
vcount(g) 
ecount(g)

g_er = erdos.renyi.game(284, p.or.m = 7840, type = "gnm", directed = TRUE)
plot(g_er, margin = -0.2, vertex.size = 5, layout = layout.kamada.kawai(g), 
     vertex.label = NA, edge.arrow.size = 0.05, vertex.color = "dark blue")
mtext("PSL E-R Network", font=2, cex=2, side = 4, line = -14, las = 2)

average.path.length(g_er)
edge_density(g_er)
hist(degree(g_er), main = "", col="dark blue", xlab = "degree(g)")
mtext("E-R Degree Distribution of PSL Network", font=2, cex=2, side = 3)
B = get.adjacency(g_er, sparse = FALSE)
er_clustering = ClustBCG(B, "directed")
er_local_clustering = er_clustering$totalCC
er_global_clustering = er_clustering$GlobaltotalCC
print(er_global_clustering)

## generating graph using Watts and Strogatz model
g_ws = sample_smallworld(dim = 1, size = 284, nei = 3, p = 0.1)
plot(g_ws, margin = -0.2, vertex.size = 5, vertex.label = NA, 
     vertex.color = "dark blue")
mtext("PSL W-S Network", font=2, cex=2, side = 4, line = -14, las = 2)

average.path.length(g_ws)
edge_density(g_ws)
hist(degree(g_ws), main = "", col="dark blue", xlab = "degree(g)")
mtext("W-S Degree Distribution of PSL Network", font=2, cex=2, side = 3)
transitivity(g_ws)

## generating graph using Barabasi-Albert (BA) model
g_ba = barabasi.game(n = 284, power=1, directed = T)
plot(g_ba, margin = -0.2, vertex.size = 5, vertex.label = NA, 
     vertex.color = "dark blue", edge.arrow.size = 0.3)
mtext("PSL B-A Network", font=2, cex=2, side = 4, line = -14, las = 2)

average.path.length(g_ba)
edge_density(g_ba)
hist(degree(g_ba), main = "", col="dark blue", xlab = "degree(g)")
mtext("B-A Degree Distribution of PSL Network", font=2, cex=2, side = 3)
transitivity(g_ba)

