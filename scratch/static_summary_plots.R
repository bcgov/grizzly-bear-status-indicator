# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

library(dplyr)

if (!exists("grizzdata_full")) load("data/grizzdata_full.rds")

sdata <- grizzdata_full %>%
  group_by(threat_class) %>%
  select(-c(geometry)) %>%
  summarize(count = n()) %>%
  filter(!is.na(threat_class))

sdata <- as.data.frame(sdata)

# drop geometry

ggplot(sdata, aes(y = count, x = threat_class)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer( palette = "Set2") +
  scale_x_discrete(limits = c("Negligible", "Low", "Medium", "High", "VHigh"))+
  geom_text(aes(label=count), vjust=0.5, hjust = 2) +
  coord_flip() +
  labs(y = "Number of Grizzly Bear Population Units", x = "Overall Threat")+
  ggtitle("Overall threat impacts to GBPU")




