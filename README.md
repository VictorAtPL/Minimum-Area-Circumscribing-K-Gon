# Fork repository README
## Python Microservice wrapping `Minimum-Area-Circumscribing-K-Gon` IDL code
This repository contains modified IDL code of upstream repository and Python code which starts HTTP microservice.
Everything is dockerized, so you can run the microservice in very smooth manner.

To build docker image run `./build_docker.sh`.
To run it, run `./run_docker.sh`.
Now, the microservice accepts connections on port *8000*. 

This is an example how I use it microservice in the client:
```python
import logging

import json_tricks
import numpy as np
import requests

LOGGER: logging.Logger = logging.getLogger()

def snip_points(points, kgon):
    x = points[:, 0]
    y = points[:, 1]

    try:
        response = requests.post(f'http://localhost:8000/test?kgon={kgon}',
                                 json=json_tricks.dumps({"x": x,
                                                         "y": y}),
                                 timeout=15)

        if response.status_code == 500:
            LOGGER.info('Request http code 500')
            return points, 500

        response_json = json_tricks.loads(response.text)

        res = response_json['response']

        res = np.transpose(res)
        res = np.concatenate([res[:, 0], res[:, 1]])
        xs = res[::2]
        ys = res[1::2]
        new_points = np.transpose(np.vstack([xs, ys]))

        return new_points, 200
    except requests.Timeout:
        LOGGER.info('Request timeout')
        return points, 408
    except requests.ConnectionError:
        LOGGER.info('Request connection error')
        return points, 404
```

# Upstream repository README
### POLY_KGON

Computes the minimum-area convex k-gon (k-sided polygon) that circumscribes the given convex n-gon. Follows the method of Aggarwal et al, "Minimum area circumscribing Polygons", The Visual Computer (1985) 1:112-117

Example:
```IDL
IDL> x = [43, 18, 19, 24, 35, 49, 56, 54]*1.
IDL> y = [24, 45, 54, 63, 69, 64, 57, 41]*1.
IDL> result = POLY_KGON(x, y, kgon=4)
IDL> print, result
      15.2727      47.2909
      28.6026      71.2848
      64.4083      58.4970
      43.5917      23.5030
```
![kgon_example](https://cloud.githubusercontent.com/assets/9730969/13654712/edf53f0c-e6ad-11e5-935d-866e70c88b83.gif)
