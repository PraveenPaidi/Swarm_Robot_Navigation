# Swarm_Robot_Navigation

 Implementing surveillance in critical areas is a significant difficulty in circumstances of secu
rity and might be very dangerous to include human beings in some situations. In pursuit of
 information about an unfamiliar or a volatile environment will pose potential risks. To address
 this concern, this project aims to mitigate these risks by employing multi-agent circular robots
 for surveillance.
 Our pipeline involves obtaining the target locations which need surveillance using a utility
 function by trading off cost and profit using density mapping[5],then customized the A star
 algorithm with orientation cost to plan the shortest path for each of the robots among the lo
cations available. We employed Linear Quadratic Regulator (LQR) to control the movement of
 the robots. We tackled multiple cases for collision avoidance with known, dynamic(unknown)
 obstacles and among the other robot agents using strategies such as negotiation by involv
ing waiting time, Artificial potential fields using estimated attractive and repulsive potentials,
 shape navigation function using vector fields and tangential velocity.
 Negotiation Algorithm majorly used to navigate the robots while avoiding collision trading
 off reaching time to save cost.[5] We employed artificial potential field to detect the dynamic
 obstacles appearing on the grid trajectory and re-plan the path. But the local minima constrain
 constituted by the concave obstacle posed an challenge. Hence the algorithm was localized to
 reach the points path planned by A* star while going around the obstacles[8].In addition to
 this, the artificial potential field [7] also used the classical step shaped path which will increase
 the cost of the our robot due to orientation cost. Hence, we had implemented the shape navi
gation function[2] to obtain an effective path to move the robots around the dynamic obstacles.
 This work is to facilitate monitoring indoor industrial areas, cluttered environment, plan
etary activities where the need of optimal surveillance with limited robots is required
