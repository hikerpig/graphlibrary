import dijkstra from './dijkstra';
import _ from '../lodash';
export default dijkstraAll;

function dijkstraAll (g, weightFunc, edgeFunc) {
  return _.transform(g.nodes(), function (acc, v) {
    acc[v] = dijkstra(g, v, weightFunc, edgeFunc)
  }, {})
}
