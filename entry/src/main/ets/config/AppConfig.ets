export class AppConfig{
  static simulationMode:boolean=false
}

export function isSimulationMode():boolean{
  return AppConfig.simulationMode
}