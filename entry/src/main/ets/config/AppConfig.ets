export class AppConfig{
  static simulationMode:boolean=true
}

export function isSimulationMode():boolean{
  return AppConfig.simulationMode
}