from __future__ import division, print_function
import numpy as np
import math

class Particle(object):
  weight=0.5
  cognitive=1
  social=2
  def __init__(self, initial_position):
    self.position=[]
    self.velocity=[]
    self.position_best=[]
    self.err_best=-1
    self.err=-1
    for i in range(0, len(initial_position)):
      self.velocity.append(np.random.uniform(-10,10))
      self.position.append(initial_position[i])
  #
  def evaluate(self, fitness_function, experiment):
    self.err=fitness_function(self.position, experiment)
    # update best individual
    if self.err < self.err_best or self.err_best==-1:
      self.position_best=self.position
      self.err_best=self.err
  #
  def update_velocity(self, pos_best_g):
    for i in range(0, len(self.position)):
      vel_cognitive = self.cognitive * np.random.random() * (self.position_best[i]-self.position[i])
      vel_social = self.social * np.random.random() * (pos_best_g[i]-self.position[i])
      self.velocity[i] = (self.weight * self.velocity[i]) + vel_cognitive + vel_social
  #
  def update_position(self, bounds):
    for i in range(0, len(self.position)):
      self.position[i]= int(self.position[i]+self.velocity[i])
      if self.position[i]>bounds[i][1]:
        self.position[i]=bounds[i][1]
      if self.position[i] < bounds[i][0]:
        self.position[i]=bounds[i][0]
  #
#

#                
class PSO(object):
  REPORT = 100
  def __init__(self, initial_position, bounds, num_particles):
    self.err_best = -1
    self.position_best = []
    self.swarm = []
    self.bounds = bounds
    self.num_particles = num_particles
    for i in range(0, self.num_particles):
      self.swarm.append(Particle(initial_position))
  #
  def optimize(self, fitness_function, max_iter, experiment):
    i=0
    while i < max_iter:
      for j in range(0, self.num_particles):
        self.swarm[j].evaluate(fitness_function, experiment)
        # update global optimum
        if self.swarm[j].err < self.err_best or self.err_best == -1:
          self.position_best = list(self.swarm[j].position)
          self.err_best = float(self.swarm[j].err)
        #
      # 
      for j in range(0, self.num_particles):
        self.swarm[j].update_velocity(self.position_best)
        self.swarm[j].update_position(self.bounds)
      #
      i+=1
      if i%self.REPORT == 0:
        print("Iter", i, "Fitness", self.err_best)      
    # print final results
    print("Final Position", self.position_best, "Fitness", self.err_best)
  #


