model TestConnectionPart

global {
	graph the_network;
	int connected <- 0;
	map strahler_numbers;
	string ss<-"../includes/nkNodesSimple.shp";
	file the_shapefile <- file(ss);
	geometry shape <- envelope(the_shapefile);

	init {
		create theEdge from: the_shapefile {
			index <- -1;
		}

		ask theEdge {
			if (index = -1) {
				connected <- connected + 1;
				index <- connected;
				mcolor<-rnd_color(255);
				list ll<-theEdge where((each.index=-1) and (shape covers each.shape));
				ask ll{
					do die;
				}

			}

		}

		write connected;
		
		save theEdge to:ss type:shp rewrite:true;
	}

//	action visit (theEdge e, rgb c) {
//		ask ((theEdge where (each.index = -1)) overlapping e) {
//			index <- connected;
//			mcolor<-c;
//			ask world {
//				do visit(myself, c);
//			}
//
//		}
//
//	}

}

species theEdge {
	int index;
	rgb mcolor;
	aspect default {
		draw shape + 5 color: mcolor;
	}

}

experiment testConnected type: gui {
	output {
		display map type:opengl{
			species theEdge aspect:default;
		}

	}

}
