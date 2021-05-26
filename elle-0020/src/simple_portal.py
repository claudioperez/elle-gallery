import anabel.backend as anp
import anabel as em

import elle.beam2d
geom_template = elle.beam2d.transform_no2(elle.beam2d.geom_no1)
beam_template = elle.beam2d.resp_no1

# Create model Assembler
model = em.SkeletalModel(ndm=2,ndf=3)

# Define problem parameters
tf, bf = model.param("tf","bf")
dw, tw = 18, 18
A  = model.expr(lambda tf, bf: bf*tf + dw*tw, tf, bf)

def moi(tf, bf):
    area = bf*tf + dw *tw
    y_c = 1/(2*area) * (tw*(dw+tf)**2 + (bf-tw)*tf**2)
    return tw*(dw+tf)**3/3 + (bf - tw)*tf**3/3 - area*y_c**2

I  = model.expr(moi, tf, bf)

# Define model components
column_section = {"A": 30**2, "E": 3600.0, "I": 30**4/12}
girder_section = {"A": A, "E": 3600.0, "I": I}
basic_girder  = beam_template(**girder_section)
basic_column  = beam_template(**column_section)

girder = geom_template(basic_girder)
column = geom_template(basic_column)

# Set up nodes
ft = 12
B, H = 30.*ft, 13.*ft
model.node("1",  0.,  0.)
model.node("2",  0.,  H )
model.node("3", B/2,  H )
model.node("4",  B ,  H )
model.node("5",  B ,  0.)

model.beam("a", "1", "2", **column_section, elem=column)
model.beam("b", "2", "3", **girder_section, elem=girder)
model.beam("c", "3", "4", **girder_section, elem=girder)
model.beam("d", "4", "5", **column_section, elem=column)

model.boun("1", [1,1,1])
model.boun("5", [1,1,1])

model.load("2", 1000.0, dof="x")
model.load("2",   -2.0, dof="y")
model.load("4",   -2.0, dof="y")

f = model.compose(_jit_force=True)
