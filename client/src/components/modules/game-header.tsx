import {
  AchievementContentProps,
  AchievementPinProps,
  CardTitle,
  cn,
  DojoIcon,
  Thumbnail,
  AchievementPinIcons,
} from "@cartridge/ui-next";
import { cva, VariantProps } from "class-variance-authority";
import { useMemo } from "react";
import banner from "@/assets/banner.png";

export interface Metadata {
  name: string;
  logo?: string;
  cover?: string;
}

export interface Socials {
  website?: string;
  discord?: string;
  telegram?: string;
  twitter?: string;
  github?: string;
}

export interface ArcadeGameHeaderProps
  extends VariantProps<typeof arcadeGameHeaderVariants> {
  metadata: Metadata;
  achievements?: {
    id: string;
    content: AchievementContentProps;
    pin?: AchievementPinProps;
  }[];
  socials?: Socials;
  active?: boolean;
  className?: string;
  color?: string;
}

export const arcadeGameHeaderVariants = cva(
  "h-16 flex justify-between items-center px-4 py-3 gap-x-3",
  {
    variants: {
      variant: {
        darkest: "bg-background-100",
        darker: "bg-background-100",
        dark: "bg-background-125",
        default: "bg-background-200 bg-top bg-cover bg-no-repeat select-none",
        light: "bg-background-200",
        lighter: "bg-background-200",
        lightest: "bg-background-200",
        ghost: "bg-transparent",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  },
);

export const ArcadeGameHeader = ({
  achievements,
  metadata,
  active,
  variant,
  className,
  color,
}: ArcadeGameHeaderProps) => {
  const pins = useMemo(() => {
    if (!achievements) return [];
    return achievements
      .filter((a) => a.content.icon && a.pin?.pinned)
      .map((a) => ({
        id: a.id,
        icon: a.content.icon || "fa-trophy",
        name: a.content.title || "",
      }))
      .slice(0, 3);
  }, [achievements]);

  const style = useMemo(() => {
    if (!!variant && variant !== "default") return {};
    const bgColor = `var(--background-200)`;
    const image = `url(${metadata.cover ? metadata.cover : banner})`;
    const colorMix = `color-mix(in srgb, ${bgColor} 100%, transparent 4%)`;
    return {
      backgroundImage: `linear-gradient(to right, ${bgColor}, ${colorMix}), ${image}`,
    };
  }, [variant, metadata.cover]);

  return (
    <div className={cn(arcadeGameHeaderVariants({ variant }))} style={style}>
      <div className="flex items-center gap-3">
        <Thumbnail
          icon={metadata.logo ?? <DojoIcon className="w-full h-full" />}
          variant={
            !variant || variant === "default" || variant?.includes("light")
              ? "light"
              : "default"
          }
          size="lg"
        />
        <CardTitle className="text-foreground-100 text-sm font-medium tracking-normal flex items-center whitespace-nowrap">
          {metadata.name}
        </CardTitle>
      </div>
      {pins.length > 0 && (
        <AchievementPinIcons
          theme={active}
          pins={pins}
          variant={variant}
          className={className}
          color={color}
        />
      )}
    </div>
  );
};

export default ArcadeGameHeader;
