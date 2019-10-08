#include "classifier.h"
#include <math.h>
#include <string>
#include <vector>
#include <fstream>
#include <iostream>

using Eigen::ArrayXd;
using std::string;
using std::vector;
using std::cout;
using std::endl;
using std::ifstream;

// Initializes GNB
GNB::GNB() {
  /**
   * TODO: Initialize GNB, if necessary. May depend on your implementation.
   */
  left_means = ArrayXd(4);
  left_means << 0,0,0,0;
  
  left_sds = ArrayXd(4);
  left_sds << 0,0,0,0;
    
  left_prior = 0;
    
  keep_means = ArrayXd(4);
  keep_means << 0,0,0,0;
  
  keep_sds = ArrayXd(4);
  keep_sds << 0,0,0,0;
  
  keep_prior = 0;
  
  right_means = ArrayXd(4);
  right_means << 0,0,0,0;
  
  right_sds = ArrayXd(4);
  right_sds << 0,0,0,0;
  
  right_prior = 0;
}

GNB::~GNB() {}


void GNB::train(const vector<vector<double>> &data, 
                const vector<string> &labels) {

  float left_size = 0;
  float keep_size = 0;
  float right_size = 0;
  float tempo = 0;
  ArrayXd data_point;
  // For each label, compute the numerators of the means for each class
  //   and the total number of data points given with that label.
  for (int i=0; i<labels.size(); ++i) {
    data_point = ArrayXd::Map(data[i].data(), data[i].size());
    
    // Pre-processing 
    //std::cout<<"actual data = " << data_point[1] <<endl;
    if (data_point[1]<=2)
        data_point[1]=data_point[1];
    else if (data_point[1]>2 && data_point[1]<=6)
        data_point[1]=data_point[1]-4.0;
    else if (data_point[1]>6 && data_point[1]<=10)
        data_point[1]=data_point[1]-8.0;
    //std::cout<<"corrected data = " << data_point[1] <<endl;
    // Pre-processing END
    
      if (labels[i] == "left") {
      // conversion of data[i] to ArrayXd
      left_means += data_point;
      left_size += 1;
    } else if (labels[i] == "keep") {
      keep_means += data_point;
      keep_size += 1;
    } else if (labels[i] == "right") {
      right_means += data_point;
      right_size += 1;
    }
  }

  // Compute the means. Each result is a ArrayXd of means 
  //   (4 means, one for each class)
  left_means = left_means/left_size;
  keep_means = keep_means/keep_size;
  right_means = right_means/right_size;
  
  // Begin computation of standard deviations for each class/label combination.
  //ArrayXd data_point;
  
  // Compute numerators of the standard deviations.
  for (int i=0; i<labels.size(); ++i) {
    data_point = ArrayXd::Map(data[i].data(), data[i].size());
    if (labels[i] == "left"){
      left_sds += (data_point - left_means)*(data_point - left_means);
    } else if (labels[i] == "keep") {
      keep_sds += (data_point - keep_means)*(data_point - keep_means);
    } else if (labels[i] == "right") {
      right_sds += (data_point - right_means)*(data_point - right_means);
    }
  }
  
  // compute standard deviations
  left_sds = (left_sds/left_size).sqrt();
  keep_sds = (keep_sds/keep_size).sqrt();
  right_sds = (right_sds/right_size).sqrt();
    
  //Compute the probability of each label
  left_prior = left_size/labels.size();
  keep_prior = keep_size/labels.size();
  right_prior = right_size/labels.size();
  
}

string GNB::predict(const vector<double> &sample) {
  /**
   * Once trained, this method is called and expected to return 
   *   a predicted behavior for the given observation.
   * @param observation - a 4 tuple with s, d, s_dot, d_dot.
   *   - Example: [3.5, 0.1, 8.5, -0.2]
   * @output A label representing the best guess of the classifier. Can
   *   be one of "left", "keep" or "right".
   *
   * TODO: Complete this function to return your classifier's prediction
   */
   double left_prob = 1.0;
   double right_prob = 1.0;
   double keep_prob = 1.0;
   
   for (int i = 0 ; i<sample.size() ; ++i){
       
        
       left_prob *= (1/sqrt(2*M_PI*pow(left_sds[i],2))) 
            * exp( -0.5 * pow(sample[i]-left_means[i],2) / (pow(left_sds[i],2)));
       right_prob *= (1/sqrt(2*M_PI*pow(right_sds[i],2))) 
            * exp( -0.5 * pow(sample[i]-right_means[i],2) / (pow(right_sds[i],2)));
       keep_prob *= (1/sqrt(2*M_PI*pow(keep_sds[i],2))) 
            * exp( -0.5 * pow(sample[i]-keep_means[i],2) / (pow(keep_sds[i],2)));
   
   }
   left_prob *= left_prior;
   right_prob *= right_prior;
   keep_prob *= keep_prior;
   
   double probs[3] = {left_prob, keep_prob, right_prob};
   double max = left_prob;
   double max_index = 0;

   for (int i=1; i<3; ++i) {
    if (probs[i] > max) {
      max = probs[i];
      max_index = i;
    }
  }
  
  
  return this -> possible_labels[max_index];
}
