package game.ui.debug;

import game.ui.mvp.IView;

/** Compact top-left debug readout. Single vertical stack of thin monospace-ish lines. */
@:uiComp("debug-overlay")
class DebugView extends h2d.Flow implements h2d.domkit.Object implements IView<DebugModel> {
	static var SRC = <debug-overlay>
		<text public id="lnPerf"   class="dbg" text={""}/>
		<text public id="lnCpu"    class="dbg" text={""}/>
		<text public id="lnGpu"    class="dbg" text={""}/>
		<text public id="lnPlayer" class="dbg" text={""}/>
		<text public id="lnWorld"  class="dbg" text={""}/>
		<text public id="lnMem"    class="dbg" text={""}/>
		<text public id="lnBoot"   class="dbg" text={""}/>
		<text public id="lnSpeed"  class="dbg" text={""}/>
		<text public id="lnZoom"   class="dbg" text={""}/>
	</debug-overlay>;

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		for (t in [lnPerf, lnCpu, lnGpu, lnPlayer, lnWorld, lnMem, lnBoot, lnSpeed, lnZoom]) {
			t.font = font;
			t.smooth = true;
		}
	}

	public function render(m:DebugModel):Void {
		lnPerf.text   = 'FPS ${m.fps}  frame ${Std.int(m.frameMs * 100) / 100}ms';
		lnCpu.text    = 'cpu ${m.cpuPct}% (js/frame)';
		lnGpu.text    = 'gpu calls ${m.drawCalls}  tris ${m.triangles}';
		lnPlayer.text = 'P ${m.playerPx}  cell ${m.playerCell}';
		lnWorld.text  = 'entities ${m.entities}';
		lnMem.text    = 'heap ${m.heapMB}';
		lnBoot.text   = 'boot ${m.startupMs}ms  up ${m.uptimeSec}s';
		lnSpeed.text  = 'speed ${m.speed}';
		lnZoom.text   = 'zoom ${m.zoom}';
	}
}
