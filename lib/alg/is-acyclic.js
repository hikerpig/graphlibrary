import topsort from './topsort';
export default isAcyclic;

function isAcyclic (g) {
  try {
    topsort(g)
  } catch (e) {
    if (e instanceof topsort.CycleException) {
      return false
    }
    throw e
  }
  return true
}
