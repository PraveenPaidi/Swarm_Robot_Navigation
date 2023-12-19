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
 this, the artificial potential field  also used the classical step shaped path which will increase
 the cost of the our robot due to orientation cost. Hence, we had implemented the shape navi
gation function to obtain an effective path to move the robots around the dynamic obstacles.

 This work is to facilitate monitoring indoor industrial areas, cluttered environment, plan
etary activities where the need of optimal surveillance with limited robots is required.

<img width="436" alt="Screenshot 2023-12-19 035336" src="https://github.com/PraveenPaidi/Swarm_Robot_Navigation/assets/120610889/f38c6f3a-403c-4be9-9bc7-e654b96800cd">
<img width="541" alt="fololo" src="https://github.com/PraveenPaidi/Swarm_Robot_Navigation/assets/120610889/69c7d63c-984c-492b-bcf0-15ee0e1c18cc">
<img width="233" alt="shape_nav" src="https://github.com/PraveenPaidi/Swarm_Robot_Navigation/assets/120610889/6852ef2e-2a27-4900-97cf-bb5f744de869">
<img width="511" alt="flow" src="https://github.com/PraveenPaidi/Swarm_Robot_Navigation/assets/120610889/7fed3ab5-f0b4-427f-bff2-17e1909d520c">


