############################################################################
## Code to run a number of scenarios testing data type (commercial, survey,
## real population), resolution (spatio-temporal) and basis for closure (high
## pop or high ratio spp1:spp2)
#############################################################################
#######################
#
## Conditioning
#
######################

library(MixFishSim)

set.seed(123, kind = "L'Ecuyer-CMRG")

## initialise the simulation

sim <- init_sim(nrows = 100, ncols = 100, n_years = 50, n_tows_day = 4, n_days_wk_fished = 5,
     n_fleets = 5, n_vessels = 20, n_species = 4, move_freq = 2)

## create the suitable habitat for each species

hab <- create_hab(sim_init = sim,
		  spp.ctrl = list(
           'spp.1' = list('nu' = 1/0.015, var = 1, scale = 10, Aniso =
           matrix(nc=2, c(1.5, 3, -3, 4))),
           'spp.2' = list('nu' = 1/0.05, var = 2, scale = 12, Aniso =
           matrix(nc=2, c(1, 2, -1, 2))),
	   'spp.3' = list('nu' = 1/0.01, var = 1, scale = 12, Aniso =
           matrix(nc=2, c(2.5, 1, -1, 2))),
           'spp.4' = list('nu' = 1/0.005, var = 1, scale = 8, Aniso =
           matrix(nc=2, c(0.1, 2, -1, 0.02)))
				  ),
		  spawn_areas = list("spp1" = list(area1 = c(40, 50, 40, 50), area2 =
				   c(80, 90, 60, 70)), 
		 "spp2" = list(area1 = c(20, 40,  0, 20), area2 = c(80, 100, 90, 100)),
		 "spp3" = list(area1 = c(20, 35, 10, 20), area2 = c(60, 70, 90, 100)),
		 "spp4" = list(area1 = c(50, 60, 80, 90), area2 = c(30, 40, 30, 40))
		 ),
		spwn_mult = 10, plot.dist = TRUE, plot.file = getwd())

## Look at overlaps of species habitats

over<-hab[["hab"]]

for(i in 1:4) {
x<- over[[i]]
x[which(x>0)] <-1
over[[i]] <- x
}

plot <- F
if(plot) {
par(mfrow = c(2,3))
image(over[[1]] + over[[2]], main = "spp1 and spp 2")
image(over[[1]] + over[[3]], main = "spp1 and spp 3")
image(over[[1]] + over[[4]], main = "spp1 and spp 4")
image(over[[2]] + over[[3]], main = "spp2 and spp 3")
image(over[[2]] + over[[4]], main = "spp2 and spp 4")
image(over[[3]] + over[[4]], main = "spp3 and spp 4")
}


#par(mfrow=c(2,2))
#for(i in 1:4) {
#image(hab[["hab"]][[i]])
#}

#habs <- Reduce("+", hab[["hab"]])
#image(habs)

## Number of non-zeros
#sapply(1:4, function(x)  {
#	       length(hab[["hab"]][[x]][hab[["hab"]][[x]]!=0]) / (100 * 100)
#		})

# Change the zeros with something v. low ?


## Initialise the populations

## Notes: A small lambda will speed up the spread of the population
##        This will reduce the need for a larger number of init_move_steps
##        which is the slower part of the function

# Define the stock recruitment parameters - these will apply to the whole pop,
# so I'm unsure of scale as yet

#Recr(model = "BH", params = list("a" = 1000, "b" = 450), 
#     B = max(Pop[["Start_pop"]][["spp1"]]), cv = 0)
#Recr(model = "BH", params = list("a" = 2000, "b" = 900), 
#     B = max(Pop[["Start_pop"]][["spp2"]]), cv = 0)

Pop <- init_pop(sim_init = sim, Bio = c(spp1 = 1e5, spp2 = 2e5, spp3 = 1e5, spp4 = 1e4), 
		hab = hab[["hab"]], start_cell = c(25,25), 
		lambda = c("spp1" = 0.1, "spp2" = 0.1, "spp3" = 0.1, "spp4" = 0.1), 
		init_move_steps = 20, 
		rec_params =  list("spp1" = c("model" = "BH", "a" = 6, "b" = 4, "cv" = 0.7), 
				   "spp2" = c("model" = "BH", "a" = 27, "b" = 4, "cv" = 0.6),
				   "spp3" = c("model" = "BH", "a" = 18, "b" = 11, "cv" = 0.7), 
				   "spp4" = c("model" = "BH", "a" =  0.3, "b" = 0.5, "cv" = 0.6)
				   ),
				   rec_wk = list("spp1" = 13:16, "spp2" = 12:16, "spp3" = 14:16, "spp4" = 16:20),
				   spwn_wk = list("spp1" = 16:18, "spp2" = 16:19, "spp3" = 16:18, "spp4" = 18:20),
				   M  = c("spp1" = 0.2, "spp2" = 0.1, "spp3" = 0.2, "spp4" = 0.1),
				   K  = c("spp1" = 0.3, "spp2" = 0.3, "spp3" = 0.3, "spp4" = 0.3))


#### Spatiotemporal movement covariates

moveCov <- init_moveCov(sim_init = sim, steps = 52, 
			spp_tol = list("spp1" = list("mu" = 12, va = 8),
				       "spp2" = list("mu" = 15, va = 8),
				       "spp3" = list("mu" = 17, va = 7), 
				       "spp4" = list("mu" = 14, va = 10)))


#plot_spatiotemp_hab(hab = hab, moveCov =, spwn_wk = list("spp1" = 16:18, "spp2" = 16:19, "spp3" = 16:18, "spp4" = 18:20))


## Initialise the fleets
Q_mult  <- 0.01

## maximum possible revenue

VPT <- c("spp1" = 100, 
	 "spp2" = 200, 
	 "spp3" = 350, 
	 "spp4" = 600)

# fleet 1
B3_1   <- quantile(sapply(1:1000, function(x) { 1 * Q_mult * Pop[["Start_pop"]][[1]][[x]] * VPT[["spp1"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[2]][[x]] * VPT[["spp2"]] +
				 1 * Q_mult * Pop[["Start_pop"]][[3]][[x]] * VPT[["spp3"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[4]][[x]] * VPT[["spp4"]] 
				   }), prob = 0.9)
# fleet 2
B3_2   <- quantile(sapply(1:1000, function(x) { 2 * Q_mult * Pop[["Start_pop"]][[1]][[x]] * VPT[["spp1"]] +
				 1 * Q_mult * Pop[["Start_pop"]][[2]][[x]] * VPT[["spp2"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[3]][[x]] * VPT[["spp3"]] +
				 1 * Q_mult * Pop[["Start_pop"]][[4]][[x]] * VPT[["spp4"]] 
				   }), prob = 0.9)

# fleet 3
B3_3 <- quantile(sapply(1:1000, function(x) { 2 * Q_mult * Pop[["Start_pop"]][[1]][[x]] * VPT[["spp1"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[2]][[x]] * VPT[["spp2"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[3]][[x]] * VPT[["spp3"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[4]][[x]] * VPT[["spp4"]]  
				   }), prob = 0.85)

# fleet 4
B3_4 <- quantile(sapply(1:1000, function(x) { 1 * Q_mult * Pop[["Start_pop"]][[1]][[x]] * VPT[["spp1"]] +
				 1 * Q_mult * Pop[["Start_pop"]][[2]][[x]] * VPT[["spp2"]] +
				 1 * Q_mult * Pop[["Start_pop"]][[3]][[x]] * VPT[["spp3"]] +
				 5 * Q_mult * Pop[["Start_pop"]][[4]][[x]] * VPT[["spp4"]] 
				   }), prob = 0.9)

# fleet 5
B3_5 <- quantile(sapply(1:1000, function(x) { 1 * Q_mult * Pop[["Start_pop"]][[1]][[x]] * VPT[["spp1"]] +
				 3 * Q_mult * Pop[["Start_pop"]][[2]][[x]] * VPT[["spp2"]] +
				 2 * Q_mult * Pop[["Start_pop"]][[3]][[x]] * VPT[["spp3"]] +
				 1 * Q_mult * Pop[["Start_pop"]][[4]][[x]] * VPT[["spp4"]] 
				   }), prob = 0.8)

#test_step(step_params = list("rate"  = 20, "B1" = 1, "B2" = 10, "B3" = B3_1), rev.max = max1)
#test_step(step_params = list("rate"  = 20, "B1" = 0.5, "B2" = 15, "B3" = max2), rev.max = max2)

fleets <- init_fleet(sim_init = sim, VPT = VPT,
	   Qs = list("fleet 1" = c("spp1" = Q_mult * 1, "spp2" = Q_mult * 1, "spp3" = Q_mult * 0.2, "spp4" = Q_mult * 1), 
		     "fleet 2" = c("spp1" = Q_mult * 3, "spp2" = Q_mult * 0.5, "spp3" = Q_mult * 1, "spp4" = Q_mult * 0.5),
		     "fleet 3" = c("spp1" = Q_mult * 2, "spp2" = Q_mult * 1, "spp3" = Q_mult * 1, "spp4" = Q_mult * 1),
		     "fleet 4" = c("spp1" = Q_mult * 1, "spp2" = Q_mult * 0.5, "spp3" = Q_mult * 0.2, "spp4" = Q_mult * 2),
		     "fleet 5" = c("spp1" = Q_mult * 1, "spp2" = Q_mult * 1, "spp3" = Q_mult * 1, "spp4" = Q_mult * 0.5)
		     ),
		     fuelC = list("fleet 1" = 3, "fleet 2" = 2, "fleet 3" = 5, "fleet 4" = 2, "fleet 5" = 1),
	   step_params = list("fleet 1" = c("rate" = 20, "B1" = 1, "B2" = 10, "B3" = B3_1),
			      "fleet 2" = c("rate" = 30, "B1" = 2 , "B2" = 15, "B3" = B3_2),
			      "fleet 3" = c("rate" = 25, "B1" = 1, "B2" =  8, "B3" = B3_3),
			      "fleet 4" = c("rate" = 35, "B1" = 2, "B2" = 12, "B3" = B3_4),
			      "fleet 5" = c("rate" = 20, "B1" = 3, "B2" =  7, "B3" = B3_5)
			      ),
	   past_knowledge = TRUE,
	   past_year_month = TRUE,
	   past_trip = TRUE,
	   threshold = 0.7)


## Setup survey
survey <- init_survey(sim_init = sim, design = "fixed_station", 
		n_stations = 100, start_day = 92, Qs = c("spp1" = 1, "spp2" = 1, "spp3" = 1, "spp4" = 1)) 

######
# Save all objects

save(sim, Pop, moveCov, fleets, hab, survey, file = "Common_Params.RData")


