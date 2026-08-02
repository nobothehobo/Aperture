package com.noah.aegis7.mixin.client;

import com.noah.aegis7.client.state.ClientRobotState;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.network.AbstractClientPlayerEntity;
import net.minecraft.client.render.entity.PlayerEntityRenderer;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Hides only the local vanilla player model while an Aegis chassis is active.
 *
 * This deliberately avoids an inherited @Shadow getModel() method. That shadow
 * does not survive Minecraft 1.21.1 production remapping reliably. Calling the
 * renderer's inherited method normally works in both named and intermediary
 * namespaces.
 */
@Mixin(PlayerEntityRenderer.class)
public abstract class PlayerEntityRendererMixin {
    @Inject(method = "setModelPose", at = @At("TAIL"))
    private void aegis7$setVanillaModelVisibility(AbstractClientPlayerEntity player, CallbackInfo ci) {
        MinecraftClient client = MinecraftClient.getInstance();
        boolean hideLocalPlayer = ClientRobotState.isMorphed() && player == client.player;
        PlayerEntityRenderer renderer = (PlayerEntityRenderer) (Object) this;
        renderer.getModel().setVisible(!hideLocalPlayer);
    }
}
