using Genie.Router
using AuthenticationController
using RectController
using TriController
using LshapeController 
using CircleController 
using SectorController
using LineController
using TrapezoidController
using PolygonController

route("/") do
  serve_static_file("welcome.html")
end

#=
This is a sample for the frequency of a 2d surface membrane .
 The sovling formula is in 'module Formula2d',
 and the other Controller for display each shape result.
=#

# 矩形, 2d rectangle membrane 
route("/rect4",RectController.base)

# 三角形, 2d triangle membrane
route("/tri3",TriController.base)

# L形, 2d L_shape membrane
route("/lshape4",LshapeController.base)

# 圆形, 2d circle shape membrane
route("/circle3",CircleController.base)

# 扇形, 2d sector shape membrane
route("/sector3",SectorController.base)

# 直线, a line
route("/line2" ,LineController.base)

# 梯形, 2d trapezoid membrane
route("/trapezoid43",TrapezoidController.base)

#多边形, 2d polygon membrane
route("/polygon3", PolygonController.base)